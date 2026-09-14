# -*- coding: utf-8 -*-
"""管理员蓝图 —— 全部后台管理功能"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from models import db
from models.models import (
    User, Employee, Hotel, Room, Order, CheckIn, Deposit,
    Service, CheckOut, Attendance, Salary,
    NewsCategory, News, Complaint, Carousel, SystemConfig
)
from utils import knn_engine
from werkzeug.security import generate_password_hash
from datetime import date, datetime
from sqlalchemy import func

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


def admin_required():
    if not current_user.is_authenticated or getattr(current_user, 'role', None) != 'admin':
        flash('需要管理员权限')
        return redirect(url_for('auth.login'))


@admin_bp.route('/')
@login_required
def dashboard():
    if getattr(current_user, 'role', None) != 'admin':
        return redirect(url_for('user.index'))
    stats = {
        'user_count': User.query.count(),
        'room_count': Room.query.count(),
        'order_count': Order.query.count(),
        'checkin_count': CheckIn.query.count(),
    }
    return render_template('admin/dashboard.html', stats=stats)


# ==================== 统计 API ====================
@admin_bp.route('/api/statistics')
@login_required
def api_statistics():
    """返回 ECharts 所需统计数据 JSON"""
    # 月度销售额 (模拟最近6个月)
    months = []
    monthly_sales = []
    for i in range(5, -1, -1):
        m = date(2026, 6, 1)  # simplified
        months.append(f'{6-i}月' if 6-i > 0 else f'{12-(i-6)}月')

    # 查询已入住和已退房的订单金额
    orders = Order.query.filter(Order.status.in_(['checked_in', 'checked_out'])).all()
    # 简化处理：均匀分配到各月
    total = sum(float(o.total_price or 0) for o in orders)
    monthly_sales = [round(total / 6 * (0.5 + i * 0.3), 2) for i in range(6)]

    # 客房销量分布 (按房型分组)
    room_type_counts = db.session.query(
        Room.room_type, func.count(Room.id)
    ).group_by(Room.room_type).all()
    room_types = [{'name': t, 'value': c} for t, c in room_type_counts]

    # 各酒店营收
    hotel_revenue = db.session.query(
        Hotel.name,
        func.coalesce(func.sum(Order.total_price), 0)
    ).outerjoin(Room, Room.hotel_id == Hotel.id)\
     .outerjoin(Order, Order.room_id == Room.id)\
     .filter(Order.status.in_(['checked_in', 'checked_out']))\
     .group_by(Hotel.id).all()
    hotel_names = [h for h, _ in hotel_revenue] if hotel_revenue else []
    hotel_revenue_data = [float(r or 0) for _, r in hotel_revenue] if hotel_revenue else []

    return jsonify({
        'months': months,
        'monthly_sales': monthly_sales,
        'room_types': room_types,
        'hotel_names': hotel_names,
        'hotel_revenue': hotel_revenue_data,
    })


# ---------- 用户管理 ----------
@admin_bp.route('/users')
@login_required
def user_list():
    users = User.query.all()
    return render_template('admin/users.html', users=users)


@admin_bp.route('/user/add', methods=['POST'])
@login_required
def user_add():
    u = User(username=request.form['username'],
             password_hash=request.form['password'],
             real_name=request.form.get('real_name'),
             phone=request.form.get('phone'))
    db.session.add(u)
    db.session.commit()
    flash('用户已添加')
    return redirect(url_for('admin.user_list'))


@admin_bp.route('/user/edit/<int:uid>', methods=['POST'])
@login_required
def user_edit(uid):
    u = db.session.get(User, uid)
    if u:
        u.real_name = request.form.get('real_name', u.real_name)
        u.phone = request.form.get('phone', u.phone)
        db.session.commit()
    flash('用户信息已更新')
    return redirect(url_for('admin.user_list'))


@admin_bp.route('/user/delete/<int:uid>', methods=['POST'])
@login_required
def user_delete(uid):
    u = db.session.get(User, uid)
    if u:
        db.session.delete(u)
        db.session.commit()
    flash('用户已删除')
    return redirect(url_for('admin.user_list'))


# ---------- 员工管理 ----------
@admin_bp.route('/employees')
@login_required
def employee_list():
    employees = Employee.query.all()
    return render_template('admin/employees.html', employees=employees)


@admin_bp.route('/employee/add', methods=['POST'])
@login_required
def employee_add():
    e = Employee(username=request.form['username'],
                 password_hash=request.form['password'],
                 real_name=request.form.get('real_name'),
                 phone=request.form.get('phone'),
                 role=request.form.get('role', 'staff'),
                 position=request.form.get('position'))
    db.session.add(e)
    db.session.commit()
    flash('员工已添加')
    return redirect(url_for('admin.employee_list'))


@admin_bp.route('/employee/edit/<int:eid>', methods=['POST'])
@login_required
def employee_edit(eid):
    e = db.session.get(Employee, eid)
    if e:
        e.real_name = request.form.get('real_name', e.real_name)
        e.phone = request.form.get('phone', e.phone)
        e.role = request.form.get('role', e.role)
        e.position = request.form.get('position', e.position)
        db.session.commit()
    flash('员工信息已更新')
    return redirect(url_for('admin.employee_list'))


@admin_bp.route('/employee/delete/<int:eid>', methods=['POST'])
@login_required
def employee_delete(eid):
    e = db.session.get(Employee, eid)
    if e:
        db.session.delete(e)
        db.session.commit()
    flash('员工已删除')
    return redirect(url_for('admin.employee_list'))


# ---------- 酒店管理 ----------
@admin_bp.route('/hotels')
@login_required
def hotel_list():
    hotels = Hotel.query.all()
    return render_template('admin/hotels.html', hotels=hotels)


@admin_bp.route('/hotel/add', methods=['POST'])
@login_required
def hotel_add():
    h = Hotel(name=request.form['name'], address=request.form.get('address'),
              star=request.form.get('star'), description=request.form.get('description'),
              image=request.form.get('image'))
    db.session.add(h)
    db.session.commit()
    flash('酒店已添加')
    return redirect(url_for('admin.hotel_list'))


@admin_bp.route('/hotel/edit/<int:hid>', methods=['POST'])
@login_required
def hotel_edit(hid):
    h = db.session.get(Hotel, hid)
    if h:
        h.name = request.form.get('name', h.name)
        h.address = request.form.get('address', h.address)
        h.star = request.form.get('star', h.star)
        h.description = request.form.get('description', h.description)
        db.session.commit()
    flash('酒店信息已更新')
    return redirect(url_for('admin.hotel_list'))


@admin_bp.route('/hotel/delete/<int:hid>', methods=['POST'])
@login_required
def hotel_delete(hid):
    h = db.session.get(Hotel, hid)
    if h:
        db.session.delete(h)
        db.session.commit()
    flash('酒店已删除')
    return redirect(url_for('admin.hotel_list'))


# ---------- 客房管理 ----------
@admin_bp.route('/rooms')
@login_required
def room_list_admin():
    keyword = request.args.get('keyword', '')
    query = Room.query
    if keyword:
        query = query.join(Hotel).filter(
            db.or_(Hotel.name.contains(keyword), Hotel.address.contains(keyword))
        )
    rooms = query.all()
    hotels = Hotel.query.all()
    return render_template('admin/rooms.html', rooms=rooms, hotels=hotels, keyword=keyword)


@admin_bp.route('/room/add', methods=['POST'])
@login_required
def room_add():
    r = Room(hotel_id=request.form['hotel_id'],
             room_number=request.form['room_number'],
             room_type=request.form.get('room_type'),
             price=request.form.get('price'),
             area=request.form.get('area'),
             bed_type=request.form.get('bed_type'),
             floor=request.form.get('floor'),
             has_breakfast=bool(request.form.get('has_breakfast')),
             rating=request.form.get('rating'),
             facilities=request.form.get('facilities'),
             description=request.form.get('description'),
             status='available')
    db.session.add(r)
    db.session.commit()
    knn_engine.update_single(r)
    flash('客房已添加，特征向量已同步')
    return redirect(url_for('admin.room_list_admin'))


@admin_bp.route('/room/edit/<int:rid>', methods=['POST'])
@login_required
def room_edit(rid):
    r = db.session.get(Room, rid)
    if r:
        r.room_type = request.form.get('room_type', r.room_type)
        r.price = request.form.get('price', r.price)
        r.area = request.form.get('area', r.area)
        r.bed_type = request.form.get('bed_type', r.bed_type)
        r.floor = request.form.get('floor', r.floor)
        r.has_breakfast = bool(request.form.get('has_breakfast'))
        r.rating = request.form.get('rating', r.rating)
        r.facilities = request.form.get('facilities', r.facilities)
        r.description = request.form.get('description', r.description)
        r.status = request.form.get('status', r.status)
        db.session.commit()
        knn_engine.update_single(r)
    flash('客房已更新，特征向量已同步')
    return redirect(url_for('admin.room_list_admin'))


@admin_bp.route('/room/delete/<int:rid>', methods=['POST'])
@login_required
def room_delete(rid):
    r = db.session.get(Room, rid)
    if r:
        db.session.delete(r)
        db.session.commit()
    flash('客房已删除')
    return redirect(url_for('admin.room_list_admin'))


# ---------- 订单 / 到店 / 入住 ----------
@admin_bp.route('/orders')
@login_required
def order_list_admin():
    orders = Order.query.order_by(Order.created_at.desc()).all()
    return render_template('admin/orders.html', orders=orders)


@admin_bp.route('/order/delete/<int:oid>', methods=['POST'])
@login_required
def order_delete(oid):
    o = db.session.get(Order, oid)
    if o:
        db.session.delete(o)
        db.session.commit()
    flash('订单已删除')
    return redirect(url_for('admin.order_list_admin'))


@admin_bp.route('/checkins')
@login_required
def checkin_list():
    checkins = CheckIn.query.order_by(CheckIn.created_at.desc()).all()
    return render_template('admin/checkins.html', checkins=checkins)


@admin_bp.route('/checkin/edit/<int:ciid>', methods=['POST'])
@login_required
def checkin_edit(ciid):
    ci = db.session.get(CheckIn, ciid)
    if ci:
        ci.id_type = request.form.get('id_type', ci.id_type)
        ci.id_number = request.form.get('id_number', ci.id_number)
        db.session.commit()
    flash('到店信息已更新')
    return redirect(url_for('admin.checkin_list'))


# ---------- 押金管理 ----------
@admin_bp.route('/deposits')
@login_required
def deposit_list():
    deposits = Deposit.query.order_by(Deposit.created_at.desc()).all()
    return render_template('admin/deposits.html', deposits=deposits)


@admin_bp.route('/deposit/refund/<int:did>', methods=['POST'])
@login_required
def deposit_refund(did):
    d = db.session.get(Deposit, did)
    if d:
        d.status = 'completed'
        refund = Deposit(order_id=d.order_id, amount=d.amount, type='refund', status='completed')
        db.session.add(refund)
        db.session.commit()
    flash('押金已退还')
    return redirect(url_for('admin.deposit_list'))


# ---------- 考勤 & 工资 ----------
@admin_bp.route('/attendance')
@login_required
def attendance_list():
    attendances = Attendance.query.order_by(Attendance.date.desc()).all()
    employees = Employee.query.filter_by(role='staff').all()
    return render_template('admin/attendance.html', attendances=attendances, employees=employees)


@admin_bp.route('/attendance/add', methods=['POST'])
@login_required
def attendance_add():
    a = Attendance(employee_id=request.form['employee_id'],
                   date=date.fromisoformat(request.form['date']),
                   status=request.form['status'])
    db.session.add(a)
    db.session.commit()
    return redirect(url_for('admin.attendance_list'))


@admin_bp.route('/attendance/edit/<int:aid>', methods=['POST'])
@login_required
def attendance_edit(aid):
    a = db.session.get(Attendance, aid)
    if a:
        a.status = request.form.get('status', a.status)
        db.session.commit()
    flash('考勤状态已更新')
    return redirect(url_for('admin.attendance_list'))


@admin_bp.route('/attendance/delete/<int:aid>', methods=['POST'])
@login_required
def attendance_delete(aid):
    a = db.session.get(Attendance, aid)
    if a:
        db.session.delete(a)
        db.session.commit()
    flash('考勤记录已删除')
    return redirect(url_for('admin.attendance_list'))
@admin_bp.route('/salaries')
@login_required
def salary_list():
    salaries = Salary.query.order_by(Salary.month.desc()).all()
    employees = Employee.query.filter_by(role='staff').all()
    return render_template('admin/salaries.html', salaries=salaries, employees=employees)


@admin_bp.route('/salary/add', methods=['POST'])
@login_required
def salary_add():
    s = Salary(employee_id=request.form['employee_id'],
               month=request.form['month'],
               basic_salary=request.form['basic_salary'],
               overtime_pay=request.form.get('overtime_pay', 0),
               bonus=request.form.get('bonus', 0),
               total=request.form['total'])
    db.session.add(s)
    db.session.commit()
    return redirect(url_for('admin.salary_list'))


@admin_bp.route('/salary/edit/<int:sid>', methods=['POST'])
@login_required
def salary_edit(sid):
    s = db.session.get(Salary, sid)
    if s:
        s.status = request.form.get('status', s.status)
        db.session.commit()
    flash('工资状态已更新')
    return redirect(url_for('admin.salary_list'))


# ---------- 资讯 ----------
@admin_bp.route('/news')
@login_required
def news_list():
    news = News.query.order_by(News.created_at.desc()).all()
    categories = NewsCategory.query.all()
    return render_template('admin/news.html', news=news, categories=categories)


@admin_bp.route('/news/add', methods=['POST'])
@login_required
def news_add():
    n = News(category_id=request.form.get('category_id'),
             title=request.form['title'],
             content=request.form.get('content'))
    db.session.add(n)
    db.session.commit()
    return redirect(url_for('admin.news_list'))


@admin_bp.route('/news/edit/<int:nid>', methods=['POST'])
@login_required
def news_edit(nid):
    n = db.session.get(News, nid)
    if n:
        n.title = request.form.get('title', n.title)
        n.content = request.form.get('content', n.content)
        n.category_id = request.form.get('category_id', n.category_id)
        db.session.commit()
    return redirect(url_for('admin.news_list'))


@admin_bp.route('/news/delete/<int:nid>', methods=['POST'])
@login_required
def news_delete(nid):
    n = db.session.get(News, nid)
    if n:
        db.session.delete(n)
        db.session.commit()
    return redirect(url_for('admin.news_list'))


# ---------- 资讯分类 ----------
@admin_bp.route('/news_category/add', methods=['POST'])
@login_required
def news_category_add():
    name = request.form.get('name', '').strip()
    if name:
        nc = NewsCategory(name=name)
        db.session.add(nc)
        db.session.commit()
        flash('分类已添加')
    return redirect(url_for('admin.news_list'))


@admin_bp.route('/news_category/delete/<int:cid>', methods=['POST'])
@login_required
def news_category_delete(cid):
    nc = db.session.get(NewsCategory, cid)
    if nc:
        db.session.delete(nc)
        db.session.commit()
        flash('分类已删除')
    return redirect(url_for('admin.news_list'))

# ---------- 投诉
# ---------- 投诉 ----------
@admin_bp.route('/complaints')
@login_required
def complaint_list():
    complaints = Complaint.query.order_by(Complaint.created_at.desc()).all()
    return render_template('admin/complaints.html', complaints=complaints)


@admin_bp.route('/complaint/reply/<int:cid>', methods=['POST'])
@login_required
def complaint_reply(cid):
    c = db.session.get(Complaint, cid)
    if c:
        c.reply = request.form['reply']
        c.status = 'resolved'
        db.session.commit()
    return redirect(url_for('admin.complaint_list'))


@admin_bp.route('/complaint/delete/<int:cid>', methods=['POST'])
@login_required
def complaint_delete(cid):
    c = db.session.get(Complaint, cid)
    if c:
        db.session.delete(c)
        db.session.commit()
    return redirect(url_for('admin.complaint_list'))


# ---------- 轮播图 ----------
@admin_bp.route('/carousels')
@login_required
def carousel_list():
    carousels = Carousel.query.order_by(Carousel.sort_order).all()
    return render_template('admin/carousels.html', carousels=carousels)


@admin_bp.route('/carousel/add', methods=['POST'])
@login_required
def carousel_add():
    c = Carousel(title=request.form['title'],
                 image_url=request.form['image_url'],
                 link_url=request.form.get('link_url'),
                 sort_order=request.form.get('sort_order', 0))
    db.session.add(c)
    db.session.commit()
    return redirect(url_for('admin.carousel_list'))


@admin_bp.route('/carousel/delete/<int:cid>', methods=['POST'])
@login_required
def carousel_delete(cid):
    c = db.session.get(Carousel, cid)
    if c:
        db.session.delete(c)
        db.session.commit()
    return redirect(url_for('admin.carousel_list'))


# ---------- 系统配置 ----------
@admin_bp.route('/config', methods=['GET', 'POST'])
@login_required
def system_config():
    if request.method == 'POST':
        for key in ['about_us', 'system_intro']:
            sc = SystemConfig.query.filter_by(config_key=key).first()
            if sc:
                sc.config_value = request.form.get(key, '')
        db.session.commit()
        flash('系统配置已更新')
    about = SystemConfig.query.filter_by(config_key='about_us').first()
    intro = SystemConfig.query.filter_by(config_key='system_intro').first()
    return render_template('admin/config.html',
                           about_us=about.config_value if about else '',
                           system_intro=intro.config_value if intro else '')


# ---------- 营业统计 (ECharts) ----------
@admin_bp.route('/statistics')
@login_required
def statistics():
    return render_template('admin/statistics.html')





