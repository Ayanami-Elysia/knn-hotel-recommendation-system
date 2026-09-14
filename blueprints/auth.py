# -*- coding: utf-8 -*-
"""用户认证蓝图"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, session

from models import db
from models.models import User, Employee
from flask_login import LoginManager, login_user, logout_user, login_required, current_user

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

login_manager = LoginManager()


@login_manager.user_loader
def load_user(user_id):
    if user_id.startswith('User-'):
        return db.session.get(User, int(user_id[5:]))
    elif user_id.startswith('Employee-'):
        return db.session.get(Employee, int(user_id[9:]))
    return None


@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user_type = request.form.get('user_type', 'user')

        if user_type == 'admin':
            emp = Employee.query.filter_by(username=username).first()
            if emp and emp.password_hash == password:
                login_user(emp)
                return redirect(url_for('admin.dashboard'))
        else:
            u = User.query.filter_by(username=username).first()
            if u and u.password_hash == password:
                login_user(u)
                return redirect(url_for('user.index'))

        flash('用户名或密码错误')
    return render_template('auth/login.html')


@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        real_name = request.form.get('real_name')
        phone = request.form.get('phone')

        if User.query.filter_by(username=username).first():
            flash('用户名已存在')
            return redirect(url_for('auth.register'))

        user = User(username=username, password_hash=password,
                    real_name=real_name, phone=phone)
        db.session.add(user)
        db.session.commit()
        flash('注册成功，请登录')
        return redirect(url_for('auth.login'))
    return render_template('auth/register.html')


@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('auth.login'))


