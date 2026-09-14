# -*- coding: utf-8 -*-
import json
import numpy as np
from sklearn.neighbors import NearestNeighbors
from sklearn.preprocessing import StandardScaler, LabelEncoder

# 房型 & 设施标签定义
ROOM_TYPES = ['标准间', '大床房', '双床房', '套房', '家庭房', '豪华套房']
BED_TYPES = ['单人床', '双人床', '大床', '特大床']
FACILITY_LIST = ['WiFi', '空调', '电视', '冰箱', '洗衣机', '热水器', '浴缸', '阳台', '办公桌', '沙发']

class KNNEngine:
    """KNN 客房推荐引擎"""

    def __init__(self):
        self.scaler = StandardScaler()
        self.knn = NearestNeighbors(n_neighbors=5, metric='cosine')
        self.room_ids = []
        self.vectors = None
        self.fitted = False

    # -------------------- 特征向量构建 --------------------
    @staticmethod
    def build_feature_vector(room):
        """根据客房属性构建标准化特征向量"""
        vec = []

        # 数值特征
        vec.append(float(room.price) if room.price else 0)
        vec.append(float(room.area) if room.area else 0)
        vec.append(float(room.floor) if room.floor else 1)
        vec.append(1.0 if room.has_breakfast else 0.0)
        vec.append(float(room.rating) if room.rating else 3.0)

        # 房型 one-hot (6维)
        rt = room.room_type if room.room_type else '标准间'
        for t in ROOM_TYPES:
            vec.append(1.0 if t == rt else 0.0)

        # 床型 one-hot (4维)
        bt = room.bed_type if room.bed_type else '双人床'
        for t in BED_TYPES:
            vec.append(1.0 if t == bt else 0.0)

        # 设施 multi-hot (10维)
        facs = [f.strip() for f in room.facilities.split(',')] if room.facilities else []
        for f in FACILITY_LIST:
            vec.append(1.0 if f in facs else 0.0)

        return np.array(vec, dtype=np.float64)

    @staticmethod
    def build_user_vector(preferences: dict):
        """根据用户偏好构建特征向量"""
        vec = []

        vec.append(float(preferences.get('budget', 500)))
        vec.append(float(preferences.get('area', 25)))
        vec.append(float(preferences.get('floor', 1)))
        vec.append(1.0 if preferences.get('has_breakfast') else 0.0)
        vec.append(float(preferences.get('min_rating', 3.0)))

        # 房型
        rt = preferences.get('room_type', '标准间')
        for t in ROOM_TYPES:
            vec.append(1.0 if t == rt else 0.0)

        # 床型
        bt = preferences.get('bed_type', '双人床')
        for t in BED_TYPES:
            vec.append(1.0 if t == bt else 0.0)

        # 设施
        req_facs = preferences.get('facilities', [])
        if isinstance(req_facs, str):
            req_facs = [f.strip() for f in req_facs.split(',')]
        for f in FACILITY_LIST:
            vec.append(1.0 if f in req_facs else 0.0)

        return np.array(vec, dtype=np.float64)

    # -------------------- 训练 & 重建索引 --------------------
    def fit(self, rooms):
        """用全部客房数据训练 KNN 模型"""
        self.room_ids = []
        vectors = []
        for room in rooms:
            v = self.build_feature_vector(room)
            vectors.append(v)
            self.room_ids.append(room.id)
        if not vectors:
            self.fitted = False
            return
        self.vectors = np.array(vectors)
        self.vectors = self.scaler.fit_transform(self.vectors)
        self.knn.fit(self.vectors)
        self.fitted = True

    def update_single(self, room):
        """更新单个客房的向量（管理员修改客房后调用）"""
        if not self.fitted:
            return
        vec = self.build_feature_vector(room)
        vec_scaled = self.scaler.transform([vec])
        if room.id in self.room_ids:
            idx = self.room_ids.index(room.id)
            self.vectors[idx] = vec_scaled[0]
            self.knn.fit(self.vectors)

    # -------------------- 推荐 --------------------
    def recommend(self, preferences: dict, top_n=5):
        """根据用户偏好返回 Top-N 推荐客房ID列表"""
        if not self.fitted or self.vectors is None or len(self.vectors) == 0:
            return []
        user_vec = self.build_user_vector(preferences)
        user_vec_scaled = self.scaler.transform([user_vec])
        k = min(top_n, len(self.vectors))
        distances, indices = self.knn.kneighbors(user_vec_scaled, n_neighbors=k)
        result = []
        for d, idx in zip(distances[0], indices[0]):
            if idx < len(self.room_ids):
                similarity = round(1 - d, 4)  # 余弦距离 → 相似度
                result.append({'room_id': self.room_ids[idx], 'similarity': similarity})
        return result


# 全局单例
knn_engine = KNNEngine()
