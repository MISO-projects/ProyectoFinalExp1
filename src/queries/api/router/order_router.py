from fastapi import APIRouter, Depends
import logging
from ..services.order_service import OrderService

order_service = OrderService()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

order_router = APIRouter()


@order_router.get("/{order_id}")
async def create_order(order_id: str, order_service: OrderService = Depends()):
    data = order_service.get_order(order_id)
    return {"data": data}
