# -*- coding: utf-8 -*-
"""从爬虫清洗数据导入到数据库"""
import json, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from models import db
from models.models import Hotel, Room
from utils import knn_engine

JSON_PATH = os.path.join(os.path.dirname(__file__), 'spider', 'cleaned_hotels.json')


def import_data():
    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        records = json.load(f)

    app = create_app()
    with app.app_context():
        imported_hotels = 0
        imported_rooms = 0

        for item in records:
            # 查找或创建酒店
            hotel = Hotel.query.filter_by(name=item['hotel_name']).first()
            if not hotel:
                hotel = Hotel(
                    name=item['hotel_name'],
                    address='上海市',  # 爬虫未提供地址，统一填上海
                    star=4,
                    description='',
                )
                db.session.add(hotel)
                db.session.flush()
                imported_hotels += 1

            # 创建客房
            room = Room(
                hotel_id=hotel.id,
                room_number=item['room_number'],
                room_type=item['room_type'],
                price=item['price'],
                area=item['area'],
                bed_type=item['bed_type'],
                floor=item['floor'],
                has_breakfast=bool(item.get('has_breakfast', 0)),
                rating=item['rating'],
                facilities=item['facilities'],
                description=item.get('description', ''),
                status=item.get('status', 'available'),
            )
            db.session.add(room)
            imported_rooms += 1

        db.session.commit()

        # 重建 KNN 索引
        all_rooms = Room.query.all()
        knn_engine.fit(all_rooms)

        print('=' * 50)
        print(f'  导入完成！')
        print(f'  新增酒店: {imported_hotels} 家')
        print(f'  新增客房: {imported_rooms} 间')
        print(f'  KNN 索引已重建 ({len(all_rooms)} 条向量)')
        print('=' * 50)


if __name__ == '__main__':
    import_data()
