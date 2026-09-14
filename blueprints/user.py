# -*- coding: utf-8 -*-
"""普通用户蓝图 —— 客房浏览、预订、收藏、入住/退房/KNN推荐"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from flask_login import login_required, current_user
from models import db
from models.models import Room, Hotel, Order, Favorite, CheckIn, Deposit, CheckOut, Service, Complaint
from utils import knn_engine
from datetime import date, datetime
import os, uuid
from werkzeug.utils import secure_filename

user_bp = Blueprint('user', __name__)

UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'static', 'uploads', 'avatars')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS



def _get_favorite_ids():
    """返回当前用户已收藏的房间ID集合"""
    if current_user.is_authenticated and current_user.__class__.__name__ == 'User':
        from models.models import Favorite
        return {fav.room_id for fav in Favorite.query.filter_by(user_id=current_user.id).all()}
    return set()


@user_bp.route('/')
def index():
    """首页 —— 展示推荐客房（暂取全部）"""
    hotels = Hotel.query.all()
    rooms = Room.query.filter_by(status='available').limit(8).all()
    return render_template('user/index.html', hotels=hotels, rooms=rooms, fav_ids=_get_favorite_ids())


@user_bp.route('/recommend', methods=['GET', 'POST'])
def recommend():
    """KNN 个性化推荐"""
    if request.method == 'POST':
        preferences = {
            'budget': request.form.get('budget'),
            'room_type': request.form.get('room_type'),
            'area': request.form.get('area'),
            'bed_type': request.form.get('bed_type'),
            'floor': request.form.get('floor'),
            'min_rating': request.form.get('min_rating'),
            'has_breakfast': request.form.get('has_breakfast') == '1',
            'facilities': request.form.get('facilities', ''),
        }
        # 过滤空值
        preferences = {k: v for k, v in preferences.items() if v not in (None, '', '不限')}
        session['last_preferences'] = {k: (int(v) if isinstance(v, bool) else v) for k, v in preferences.items()}

        results = knn_engine.recommend(preferences, top_n=5)
        recommended_rooms = []
        for item in results:
            room = db.session.get(Room, item['room_id'])
            if room:
                recommended_rooms.append({'room': room, 'similarity': item['similarity']})
        return render_template('user/recommend.html', rooms=recommended_rooms, preferences=preferences, fav_ids=_get_favorite_ids())

    preferences = session.get('last_preferences', {})
    if preferences:
        results = knn_engine.recommend(preferences, top_n=5)
        recommended_rooms = []
        for item in results:
            room = db.session.get(Room, item['room_id'])
            if room:
                recommended_rooms.append({'room': room, 'similarity': item['similarity']})
        return render_template('user/recommend.html', rooms=recommended_rooms, preferences=preferences, fav_ids=_get_favorite_ids())
    return render_template('user/recommend.html', rooms=[], preferences={}, fav_ids=_get_favorite_ids())


@user_bp.route('/rooms')
def room_list():
    """客房列表 / 搜索"""
    keyword = request.args.get('keyword', '')
    query = Room.query.filter_by(status='available')
    if keyword:
        query = query.join(Hotel).filter(
            db.or_(Hotel.name.contains(keyword), Hotel.address.contains(keyword))
        )
    rooms = query.all()
    return render_template('user/rooms.html', rooms=rooms, keyword=keyword, fav_ids=_get_favorite_ids())


@user_bp.route('/room/<int:room_id>')
def room_detail(room_id):
    """客房详情"""
    room = db.session.get(Room, room_id)
    if not room:
        flash('客房不存在')
        return redirect(url_for('user.room_list'))
    return render_template('user/room_detail.html', room=room, fav_ids=_get_favorite_ids())


@user_bp.route('/favorite/<int:room_id>', methods=['POST'])
@login_required
def toggle_favorite(room_id):
    """收藏 / 取消收藏"""
    fav = Favorite.query.filter_by(user_id=current_user.id, room_id=room_id).first()
    if fav:
        db.session.delete(fav)
    else:
        db.session.add(Favorite(user_id=current_user.id, room_id=room_id))
    db.session.commit()
    return redirect(request.referrer or url_for('user.room_list'))


@user_bp.route('/favorites')
@login_required
def favorites():
    favs = Favorite.query.filter_by(user_id=current_user.id).all()
    return render_template('user/favorites.html', favorites=favs)


@user_bp.route('/order/create/<int:room_id>', methods=['GET', 'POST'])
@login_required
def create_order(room_id):
    room = db.session.get(Room, room_id)
    if not room:
        flash('客房不存在')
        return redirect(url_for('user.room_list'))

    if request.method == 'POST':
        guest_name = request.form.get('guest_name')
        guest_phone = request.form.get('guest_phone')
        check_in_date = request.form.get('check_in_date')
        check_out_date = request.form.get('check_out_date')

        order = Order(user_id=current_user.id, room_id=room.id,
                      guest_name=guest_name, guest_phone=guest_phone,
                      check_in_date=date.fromisoformat(check_in_date),
                      check_out_date=date.fromisoformat(check_out_date),
                      total_price=room.price,
                      status='pending')
        db.session.add(order)
        db.session.commit()
        flash('预订成功，等待确认')
        return redirect(url_for('user.orders'))
    return render_template('user/create_order.html', room=room)


@user_bp.route('/orders')
@login_required
def orders():
    orders = Order.query.filter_by(user_id=current_user.id).order_by(Order.created_at.desc()).all()
    return render_template('user/orders.html', orders=orders)


@user_bp.route('/checkin/<int:order_id>', methods=['POST'])
@login_required
def checkin(order_id):
    order = Order.query.filter(Order.id==order_id, Order.user_id==current_user.id, Order.status.in_(['pending','confirmed','checked_in'])).first()
    if not order:
        flash('订单不存在')
        return redirect(url_for('user.orders'))

    ci = CheckIn(order_id=order.id, actual_check_in_time=datetime.now(),
                 id_type=request.form.get('id_type'),
                 id_number=request.form.get('id_number'))
    order.status = 'checked_in'
    db.session.add(ci)
    db.session.commit()
    flash('到店登记成功')
    return redirect(url_for('user.orders'))


@user_bp.route('/deposit/<int:order_id>', methods=['POST'])
@login_required
def pay_deposit(order_id):
    order = Order.query.filter(Order.id==order_id, Order.user_id==current_user.id, Order.status.in_(['pending','confirmed','checked_in'])).first()
    if not order:
        flash('订单不存在')
        return redirect(url_for('user.orders'))

    amount = request.form.get('amount', 100)
    d = Deposit(order_id=order.id, amount=amount, type='pay', status='completed')
    db.session.add(d)
    db.session.commit()
    flash('押金缴纳成功')
    return redirect(url_for('user.orders'))


@user_bp.route('/checkout/<int:order_id>', methods=['POST'])
@login_required
def checkout(order_id):
    order = Order.query.filter_by(id=order_id, user_id=current_user.id, status='checked_in').first()
    if not order:
        flash('订单不存在或未入住')
        return redirect(url_for('user.orders'))

    ci = order.check_in
    co = CheckOut(check_in_id=ci.id, check_out_time=datetime.now(),
                  total_fee=order.total_price, deposit_refunded=100)
    order.status = 'checked_out'
    db.session.add(co)
    db.session.commit()
    flash('退房成功')
    return redirect(url_for('user.orders'))


@user_bp.route('/service/<int:order_id>', methods=['POST'])
@login_required
def request_service(order_id):
    order = Order.query.filter_by(id=order_id, user_id=current_user.id, status='checked_in').first()
    if not order or not order.check_in:
        flash('无法申请服务')
        return redirect(url_for('user.orders'))

    sv = Service(check_in_id=order.check_in.id,
                 service_type=request.form.get('service_type'),
                 description=request.form.get('description'))
    db.session.add(sv)
    db.session.commit()
    flash('服务申请已提交')
    return redirect(url_for('user.orders'))


@user_bp.route('/profile', methods=['GET', 'POST'])
@login_required
def profile():
    if request.method == 'POST':
        current_user.real_name = request.form.get('real_name')
        current_user.phone = request.form.get('phone')

        # 头像上传
        file = request.files.get('avatar')
        if file and file.filename and allowed_file(file.filename):
            ext = file.filename.rsplit('.', 1)[1].lower()
            filename = f'{uuid.uuid4().hex}.{ext}'
            os.makedirs(UPLOAD_FOLDER, exist_ok=True)
            file.save(os.path.join(UPLOAD_FOLDER, filename))
            current_user.avatar = f'/static/uploads/avatars/{filename}'

        db.session.commit()
        flash('个人信息已更新')
    return render_template('user/profile.html')


# ==================== 投诉留言 ====================
@user_bp.route('/complaints', methods=['GET', 'POST'])
@login_required
def complaints():
    if request.method == 'POST':
        content = request.form.get('content', '').strip()
        if content:
            c = Complaint(user_id=current_user.id, content=content)
            db.session.add(c)
            db.session.commit()
            flash('投诉/留言已提交')
        else:
            flash('内容不能为空')
        return redirect(url_for('user.complaints'))
    my_complaints = Complaint.query.filter_by(user_id=current_user.id).order_by(Complaint.created_at.desc()).all()
    return render_template('user/complaints.html', complaints=my_complaints)





