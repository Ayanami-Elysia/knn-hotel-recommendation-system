# -*- coding: utf-8 -*-
"""种子数据脚本 —— 开发阶段用模拟数据驱动"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from models import db
from models.models import (
    User, Employee, Hotel, Room, Order, CheckIn, Deposit,
    Service, CheckOut, Favorite, Attendance, Salary,
    NewsCategory, News, Complaint, Carousel, SystemConfig
)
from datetime import date, datetime, timedelta
from werkzeug.security import generate_password_hash


def seed():
    app = create_app()
    with app.app_context():
        db.drop_all()
        db.create_all()

        # ---------- 管理员 & 员工 ----------
        e1 = Employee(username='admin', password_hash='123456',
                      real_name='系统管理员', role='admin', position='总经理')
        e2 = Employee(username='staff01', password_hash='123456',
                      real_name='张三', role='staff', position='前台')
        e3 = Employee(username='staff02', password_hash='123456',
                      real_name='李四', role='staff', position='客房服务')
        db.session.add_all([e1, e2, e3])
        db.session.flush()

        # ---------- 用户 ----------
        u1 = User(username='testuser', password_hash='123456',
                  real_name='测试用户', phone='13800000001')
        u2 = User(username='wangwu', password_hash='123456',
                  real_name='王五', phone='13800000002')
        db.session.add_all([u1, u2, u3])
        db.session.flush()

        # ---------- 酒店 ----------
        h1 = Hotel(name='悦海国际大酒店', address='上海市浦东新区陆家嘴金融贸易区世纪大道100号', star=5,
                   description='五星级豪华商务酒店，坐落于陆家嘴核心地段，拥有无敌江景。',
                   image='/static/images/default-hotel.svg')
        h2 = Hotel(name='西湖湖畔度假酒店', address='杭州市西湖区北山路78号', star=4,
                   description='紧邻西湖，环境优雅，是休闲度假的理想之选。',
                   image='/static/images/default-hotel.svg')
        h3 = Hotel(name='京城阳光快捷酒店', address='北京市朝阳区建国路88号', star=3,
                   description='经济实惠的商务快捷酒店，交通便利性价比高。',
                   image='/static/images/default-hotel.svg')
        db.session.add_all([h1, h2, h3])
        db.session.flush()

        # ---------- 客房 ----------
        rooms_data = [
            # hotel 1
            {'hotel_id': h1.id, 'room_number': '1801', 'room_type': '豪华套房', 'price': 2888, 'area': 80,
             'bed_type': '特大床', 'floor': 18, 'has_breakfast': True, 'rating': 4.9,
             'facilities': 'WiFi,空调,电视,冰箱,浴缸,阳台,办公桌,沙发',
             'status': 'available', 'description': '180平米豪华江景套房，带独立书房和按摩浴缸'},
            {'hotel_id': h1.id, 'room_number': '1205', 'room_type': '大床房', 'price': 1288, 'area': 45,
             'bed_type': '大床', 'floor': 12, 'has_breakfast': True, 'rating': 4.7,
             'facilities': 'WiFi,空调,电视,冰箱',
             'status': 'available', 'description': '朝南观景大床房，40寸智能电视'},
            {'hotel_id': h1.id, 'room_number': '805', 'room_type': '标准间', 'price': 888, 'area': 30,
             'bed_type': '双人床', 'floor': 8, 'has_breakfast': False, 'rating': 4.3,
             'facilities': 'WiFi,空调,电视',
             'status': 'available', 'description': '舒适标准间，含独立卫浴'},
            # hotel 2
            {'hotel_id': h2.id, 'room_number': '301', 'room_type': '套房', 'price': 1688, 'area': 65,
             'bed_type': '大床', 'floor': 3, 'has_breakfast': True, 'rating': 4.8,
             'facilities': 'WiFi,空调,电视,冰箱,浴缸,阳台,办公桌',
             'status': 'available', 'description': '湖景套房，带露台花园'},
            {'hotel_id': h2.id, 'room_number': '205', 'room_type': '双床房', 'price': 788, 'area': 35,
             'bed_type': '单人床', 'floor': 2, 'has_breakfast': True, 'rating': 4.5,
             'facilities': 'WiFi,空调,电视',
             'status': 'available', 'description': '精致双床房，园林景观窗'},
            {'hotel_id': h2.id, 'room_number': '101', 'room_type': '大床房', 'price': 588, 'area': 28,
             'bed_type': '双人床', 'floor': 1, 'has_breakfast': False, 'rating': 4.2,
             'facilities': 'WiFi,空调,电视',
             'status': 'available', 'description': '经济大床房，温馨舒适'},
            # hotel 3
            {'hotel_id': h3.id, 'room_number': '501', 'room_type': '标准间', 'price': 388, 'area': 22,
             'bed_type': '单人床', 'floor': 5, 'has_breakfast': False, 'rating': 4.0,
             'facilities': 'WiFi,空调,电视',
             'status': 'available', 'description': '经济标准间，干净整洁'},
            {'hotel_id': h3.id, 'room_number': '302', 'room_type': '大床房', 'price': 488, 'area': 26,
             'bed_type': '大床', 'floor': 3, 'has_breakfast': False, 'rating': 4.1,
             'facilities': 'WiFi,空调,电视,办公桌',
             'status': 'available', 'description': '商务大床房，配备办公桌'},
            {'hotel_id': h3.id, 'room_number': '201', 'room_type': '家庭房', 'price': 688, 'area': 40,
             'bed_type': '双人床', 'floor': 2, 'has_breakfast': True, 'rating': 4.3,
             'facilities': 'WiFi,空调,电视,冰箱,洗衣机',
             'status': 'available', 'description': '家庭套房，可加婴儿床'},
        ]
        room_objects = []
        for rd in rooms_data:
            room = Room(**rd)
            db.session.add(room)
            room_objects.append(room)
        db.session.flush()

        # ---------- 订单 & 到店 & 押金 ----------
        o1 = Order(user_id=u1.id, room_id=room_objects[0].id, guest_name='测试用户',
                   guest_phone='13800000001', check_in_date=date(2026, 6, 25),
                   check_out_date=date(2026, 6, 28),
                   total_price=2888 * 3, status='checked_in')
        db.session.add(o1)
        db.session.flush()

        ci1 = CheckIn(order_id=o1.id, actual_check_in_time=datetime(2026, 6, 25, 14, 0),
                      id_type='身份证', id_number='310101199001010001')
        db.session.add(ci1)
        db.session.flush()

        d1 = Deposit(order_id=o1.id, amount=100, type='pay', status='completed')
        db.session.add(d1)

        # ---------- 收藏 ----------
        f1 = Favorite(user_id=u1.id, room_id=room_objects[1].id)
        f2 = Favorite(user_id=u1.id, room_id=room_objects[3].id)
        db.session.add_all([f1, f2])

        # ---------- 考勤 ----------
        a1 = Attendance(employee_id=e2.id, date=date(2026, 6, 20), status='normal')
        a2 = Attendance(employee_id=e2.id, date=date(2026, 6, 21), status='late')
        a3 = Attendance(employee_id=e3.id, date=date(2026, 6, 20), status='normal')
        db.session.add_all([a1, a2, a3])

        # ---------- 工资 ----------
        s1 = Salary(employee_id=e2.id, month='2026-06', basic_salary=5000, overtime_pay=300,
                    bonus=500, total=5800, status='paid')
        s2 = Salary(employee_id=e3.id, month='2026-06', basic_salary=4500, overtime_pay=0,
                    bonus=200, total=4700, status='pending')
        db.session.add_all([s1, s2])

        # ---------- 资讯 ----------
        nc1 = NewsCategory(name='酒店动态')
        nc2 = NewsCategory(name='优惠活动')
        db.session.add_all([nc1, nc2])
        db.session.flush()

        n1 = News(category_id=nc1.id, title='悦海国际荣获2026年度最佳商务酒店奖',
                  content='经过激烈评选，悦海国际大酒店凭借卓越服务荣获年度大奖...')
        n2 = News(category_id=nc2.id, title='暑期家庭套房8折优惠',
                  content='即日起至2026年8月31日，预订家庭套房享8折优惠...')
        db.session.add_all([n1, n2])

        # ---------- 投诉 ----------
        c1 = Complaint(user_id=u1.id, content='空调制冷效果不好', status='pending')
        db.session.add(c1)

        # ---------- 轮播图 ----------
        ca1 = Carousel(title='暑期特惠', image_url='/static/images/banner1.svg', sort_order=1)
        ca2 = Carousel(title='商务出行首选', image_url='/static/images/banner2.svg', sort_order=2)
        db.session.add_all([ca1, ca2])

        # ---------- 系统配置 ----------
        sc1 = SystemConfig(config_key='about_us',
                           config_value='本系统是基于KNN推荐算法的酒店客房管理平台，致力于为用户提供个性化酒店推荐服务。')
        sc2 = SystemConfig(config_key='system_intro',
                           config_value='欢迎使用智能酒店客房管理系统，支持客房浏览、在线预订、个性化推荐、到店入住等一站式服务。')
        db.session.add_all([sc1, sc2])

        db.session.commit()
        print('=' * 50)
        print('  种子数据初始化完成！')
        print('  管理员: admin / 123456')
        print('  用户:   testuser / 123456')
        print('=' * 50)


if __name__ == '__main__':
    seed()






