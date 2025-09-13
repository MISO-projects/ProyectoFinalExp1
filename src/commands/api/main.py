from fastapi import FastAPI, Request, HTTPException
from .services.order_service import OrderService

app = FastAPI()
order_service = OrderService()


@app.post("/")
async def create_order(request: Request):
    body = await request.json()

    if order_service.create_order(body):
        return {"message": "OK"}
    else:
        raise HTTPException(status_code=500, detail="Failed to add row")
