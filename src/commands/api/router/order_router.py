from fastapi import APIRouter, Depends, HTTPException, status
import logging
from ..schemas.orden_schema import CrearOrdenSchema
from ..services.order_service import OrderService

order_service = OrderService()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

order_router = APIRouter()


@order_router.post("/")
async def create_order(order: CrearOrdenSchema):
    order_service.create_order(order.model_dump())
    return {"message": "Orden creada correctamente"}
