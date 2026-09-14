# -*- coding: utf-8 -*-
from flask import Flask
from models import db
from utils import knn_engine
from models.models import Room, User, Employee
from blueprints.auth import login_manager
from config import config


def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = config.SQLALCHEMY_DATABASE_URI
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = config.SQLALCHEMY_TRACK_MODIFICATIONS
    app.config['SECRET_KEY'] = config.SECRET_KEY

    db.init_app(app)
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'

    with app.app_context():
        from models import models
        db.create_all()

        all_rooms = Room.query.all()
        knn_engine.fit(all_rooms)

    from blueprints.auth import auth_bp
    from blueprints.user import user_bp
    from blueprints.admin import admin_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(admin_bp)

    return app


if __name__ == '__main__':
    application = create_app()
    application.run(debug=True)
