# -*- coding: utf-8 -*-
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime

db = SQLAlchemy()

# ==================== 鐢ㄦ埛琛?====================
class User(db.Model, UserMixin):

    def get_id(self):
        return f'User-{self.id}'

    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    real_name = db.Column(db.String(50))
    phone = db.Column(db.String(20))
    avatar = db.Column(db.String(256))
    created_at = db.Column(db.DateTime, default=datetime.now)

    orders = db.relationship('Order', backref='user', lazy='dynamic')
    favorites = db.relationship('Favorite', backref='user', lazy='dynamic')
    complaints = db.relationship('Complaint', backref='user', lazy='dynamic')

# ==================== 鍛樺伐琛紙鍚鐞嗗憳锛?====================
class Employee(db.Model, UserMixin):

    def get_id(self):
        return f'Employee-{self.id}'

    __tablename__ = 'employees'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    real_name = db.Column(db.String(50))
    phone = db.Column(db.String(20))
    role = db.Column(db.String(20), default='staff')   # admin / staff
    position = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.now)

    attendances = db.relationship('Attendance', backref='employee', lazy='dynamic')
    salaries = db.relationship('Salary', backref='employee', lazy='dynamic')

# ==================== 閰掑簵琛?====================
class Hotel(db.Model):
    __tablename__ = 'hotels'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(300), nullable=False)
    address = db.Column(db.String(256))
    star = db.Column(db.Integer)
    description = db.Column(db.Text)
    image = db.Column(db.String(256))
    created_at = db.Column(db.DateTime, default=datetime.now)

    rooms = db.relationship('Room', backref='hotel', lazy='dynamic')

# ==================== 瀹㈡埧琛?====================
class Room(db.Model):
    __tablename__ = 'rooms'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    hotel_id = db.Column(db.Integer, db.ForeignKey('hotels.id'), nullable=False)
    room_number = db.Column(db.String(20))
    room_type = db.Column(db.String(30))         # 鏍囧噯闂?澶у簥鎴?鍙屽簥鎴?濂楁埧/瀹跺涵鎴?璞崕濂楁埧
    price = db.Column(db.Numeric(10, 2))
    area = db.Column(db.Numeric(6, 2))
    bed_type = db.Column(db.String(20))          # 单人床/双人床/大床/特大床
    floor = db.Column(db.Integer)
    has_breakfast = db.Column(db.Boolean, default=False)
    rating = db.Column(db.Numeric(3, 2))         # 0-5
    facilities = db.Column(db.String(256))       # 閫楀彿鍒嗛殧: WiFi,绌鸿皟,鐢佃,鍐扮...
    feature_vector = db.Column(db.Text)          # JSON, KNN鐗瑰緛鍚戦噺
    status = db.Column(db.String(20), default='available')  # available/booked/maintenance
    image = db.Column(db.String(256))
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)

    orders = db.relationship('Order', backref='room', lazy='dynamic')
    favorites = db.relationship('Favorite', backref='room', lazy='dynamic')

# ==================== 璁㈠崟琛?====================
class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    room_id = db.Column(db.Integer, db.ForeignKey('rooms.id'), nullable=False)
    guest_name = db.Column(db.String(50))
    guest_phone = db.Column(db.String(20))
    check_in_date = db.Column(db.Date)
    check_out_date = db.Column(db.Date)
    total_price = db.Column(db.Numeric(10, 2))
    status = db.Column(db.String(20), default='pending')  # pending/confirmed/checked_in/checked_out/cancelled
    created_at = db.Column(db.DateTime, default=datetime.now)

    check_in = db.relationship('CheckIn', backref='order', uselist=False, lazy=True)
    deposits = db.relationship('Deposit', backref='order', lazy='dynamic')

# ==================== 鍒板簵鐧昏琛?====================
class CheckIn(db.Model):
    __tablename__ = 'check_ins'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), unique=True, nullable=False)
    actual_check_in_time = db.Column(db.DateTime)
    id_type = db.Column(db.String(20))           # 韬唤璇?鎶ょ収
    id_number = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.now)

    services = db.relationship('Service', backref='check_in', lazy='dynamic')
    check_out = db.relationship('CheckOut', backref='check_in', uselist=False, lazy=True)

# ==================== 鎶奸噾琛?====================
class Deposit(db.Model):
    __tablename__ = 'deposits'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)
    amount = db.Column(db.Numeric(10, 2))
    type = db.Column(db.String(20))              # pay / refund
    status = db.Column(db.String(20), default='pending')  # pending/completed
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 瀹㈡埧鏈嶅姟琛?====================
class Service(db.Model):
    __tablename__ = 'services'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    check_in_id = db.Column(db.Integer, db.ForeignKey('check_ins.id'), nullable=False)
    service_type = db.Column(db.String(30))      # cleaning/supplies/maintenance
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')  # pending/processing/completed
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 閫€鎴胯〃 ====================
class CheckOut(db.Model):
    __tablename__ = 'check_outs'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    check_in_id = db.Column(db.Integer, db.ForeignKey('check_ins.id'), unique=True, nullable=False)
    check_out_time = db.Column(db.DateTime)
    total_fee = db.Column(db.Numeric(10, 2))
    deposit_refunded = db.Column(db.Numeric(10, 2))
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 鏀惰棌琛?====================
class Favorite(db.Model):
    __tablename__ = 'favorites'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    room_id = db.Column(db.Integer, db.ForeignKey('rooms.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

    __table_args__ = (db.UniqueConstraint('user_id', 'room_id', name='uq_user_room'),)

# ==================== 鑰冨嫟琛?====================
class Attendance(db.Model):
    __tablename__ = 'attendance'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    date = db.Column(db.Date)
    status = db.Column(db.String(20))            # normal/late/early/absent
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 宸ヨ祫琛?====================
class Salary(db.Model):
    __tablename__ = 'salaries'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    month = db.Column(db.String(7))              # '2026-06'
    basic_salary = db.Column(db.Numeric(10, 2))
    overtime_pay = db.Column(db.Numeric(10, 2))
    bonus = db.Column(db.Numeric(10, 2))
    total = db.Column(db.Numeric(10, 2))
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 璧勮鍒嗙被琛?====================
class NewsCategory(db.Model):
    __tablename__ = 'news_categories'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

    news_list = db.relationship('News', backref='category', lazy='dynamic')

# ==================== 璧勮琛?====================
class News(db.Model):
    __tablename__ = 'news'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    category_id = db.Column(db.Integer, db.ForeignKey('news_categories.id'))
    title = db.Column(db.String(200))
    content = db.Column(db.Text)
    image = db.Column(db.String(256))
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 鎶曡瘔鐣欒█琛?====================
class Complaint(db.Model):
    __tablename__ = 'complaints'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    content = db.Column(db.Text)
    reply = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')  # pending/resolved
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 杞挱鍥捐〃 ====================
class Carousel(db.Model):
    __tablename__ = 'carousels'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String(100))
    image_url = db.Column(db.String(256))
    link_url = db.Column(db.String(256))
    sort_order = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.now)

# ==================== 绯荤粺閰嶇疆琛?====================
class SystemConfig(db.Model):
    __tablename__ = 'system_config'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    config_key = db.Column(db.String(50), unique=True, nullable=False)
    config_value = db.Column(db.Text)


