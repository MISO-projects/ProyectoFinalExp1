from typing import Dict, Any
from sqlalchemy.orm import Session
from ..db.database import get_db
from fastapi import Depends
from ..db.order_projection_model import OrderProjection
from fastapi import HTTPException
from http import HTTPStatus


class OrderService:
    def __init__(self, db: Session = Depends(get_db)):
        self.db = db

    def get_order(self, order_id: str) -> Dict[str, Any]:
        order = (
            self.db.query(OrderProjection)
            .filter(OrderProjection.id == order_id)
            .first()
        )
        if not order:
            raise HTTPException(
                status_code=HTTPStatus.NOT_FOUND,
                detail='Order not found.',
            )
        return order.to_dict()
