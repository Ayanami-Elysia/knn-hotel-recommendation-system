# -*- coding: utf-8 -*-
"""初始化管理员和用户账号"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from models import db
from models.models import User, Employee
from werkzeug.security import generate_password_hash

app = create_app()
with app.app_context():
    db.drop_all()
    db.create_all()

    # Admin employee
    admin_emp = Employee(username='admin', password_hash='123456',
                         real_name='系统管理员', role='admin', position='总经理')
    db.session.add(admin_emp)

    # Admin user (user table)
    admin_user = User(username='admin', password_hash='123456',
                      real_name='管理员用户', phone='13900000000')
    db.session.add(admin_user)

    # Regular user
    user = User(username='user', password_hash='123456',
                real_name='普通用户', phone='13800000000')
    db.session.add(user)

    db.session.commit()
    print('=' * 50)
    print('  账号初始化完成！')
    print('  管理员(员工): admin / 123456')
    print('  管理员(用户): admin / 123456')
    print('  用户:   user  / 123456')
    print('=' * 50)


