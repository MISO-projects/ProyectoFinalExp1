from typing import Dict, Any
from sqlalchemy.orm import Session
from ..db.order_model import Orden, DetalleOrden
from fastapi import Depends
from ..db.database import get_db
from datetime import datetime
from ..services.pubsub_service import PubSubService
from ..services.pubsub_service import get_pubsub_service


class OrderHandler:
    def __init__(
        self,
        db: Session = Depends(get_db),
        pubsub_service: PubSubService = Depends(get_pubsub_service),
    ):
        self.db = db
        self.pubsub_service = pubsub_service

    def handle_order(self, order_data: Dict[str, Any]):
        order = Orden(
            estado="PENDIENTE",
            fecha_entrega_estimada=datetime.fromisoformat(
                order_data["fecha_entrega_estimada"]
            ),
            observaciones=order_data["observaciones"],
            id_cliente=order_data["id_cliente"],
            id_vendedor=order_data["id_vendedor"],
            id_bodega_origen=order_data["id_bodega_origen"],
            creado_por=order_data["creado_por"],
        )
        detalle_orden = []
        valor_total = 0
        for detalle in order_data["detalles"]:
            valor_total += detalle["precio_unitario"] * detalle["cantidad"]
            detalle_orden.append(
                DetalleOrden(
                    id_orden=order.id,
                    id_producto=detalle["id_producto"],
                    cantidad=detalle["cantidad"],
                    precio_unitario=detalle["precio_unitario"],
                    observaciones=detalle["observaciones"],
                )
            )
        order.detalles = detalle_orden
        order.valor_total = valor_total
        self.db.add(order)
        self.db.commit()
        self.db.refresh(order)
        self.publish_order_created_event(order)
        return order

    def publish_order_created_event(self, orden: Orden):
        order_data = orden.to_dict()
        order_data["detalles"] = [detalle.to_dict() for detalle in orden.detalles]
        self.pubsub_service.publish_order_created_event(order_data)
