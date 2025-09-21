from fastapi import FastAPI, Request, HTTPException
from .schemas.orden_schema import CrearOrdenSchema
from .services.order_service import OrderService
import logging


order_service = OrderService()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
app = FastAPI()


@app.post("/")
async def create_order(order: CrearOrdenSchema):
    order_service.create_order(order.model_dump())
    return {"message": "Orden creada correctamente"}
