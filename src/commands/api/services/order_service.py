from .pubsub_service import PubSubService
from typing import Dict, Any


class OrderService:
    def __init__(self, pubsub_service: PubSubService = None):
        self.pubsub_service = pubsub_service or PubSubService()

    def create_order(self, order_data: Dict[str, Any]) -> bool:
        return self.pubsub_service.publish_create_order_command(order_data)
