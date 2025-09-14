from sqlalchemy import Column, DateTime, Integer, String, Numeric, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid

from .database import Base
from sqlalchemy.dialects.postgresql import UUID


class DetalleOrden(Base):
    __tablename__ = "detalles_ordenes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    fecha_creacion = Column(DateTime, default=datetime.now())
    fecha_actualizacion = Column(DateTime, default=datetime.now())
    id_orden = Column(UUID(as_uuid=True), ForeignKey("ordenes.id"), nullable=False)
    id_producto = Column(UUID(as_uuid=True), nullable=False)
    cantidad = Column(Integer, nullable=False)
    precio_unitario = Column(Numeric, nullable=False)
    subtotal = Column(Numeric, nullable=False)
    observaciones = Column(String, nullable=True)
    orden = relationship("Orden", back_populates="detalles")

    def __init__(self, id_orden, id_producto, cantidad, precio_unitario, observaciones):
        now = datetime.now(timezone.utc)
        self.fecha_creacion = now
        self.fecha_actualizacion = now
        self.id_orden = id_orden
        self.id_producto = id_producto
        self.cantidad = cantidad
        self.precio_unitario = precio_unitario
        self.subtotal = precio_unitario * cantidad
        self.observaciones = observaciones


class Orden(Base):
    __tablename__ = "ordenes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    fecha_creacion = Column(DateTime, default=datetime.now())
    fecha_actualizacion = Column(DateTime, default=datetime.now())
    numero_orden = Column(String, nullable=False, unique=True)
    estado = Column(String, nullable=False)
    valor_total = Column(Numeric, nullable=False)
    id_cliente = Column(UUID(as_uuid=True), nullable=False)
    id_vendedor = Column(UUID(as_uuid=True), nullable=False)
    id_bodega_origen = Column(UUID(as_uuid=True), nullable=False)
    creado_por = Column(UUID(as_uuid=True), nullable=False)
    fecha_entrega_estimada = Column(DateTime, nullable=False)
    observaciones = Column(String, nullable=True)
    detalles = relationship("DetalleOrden", back_populates="orden")

    def __init__(self, estado, id_cliente, id_vendedor, id_bodega_origen, creado_por, fecha_entrega_estimada, observaciones):
        now = datetime.now(timezone.utc)
        self.fecha_creacion = now
        self.fecha_actualizacion = now
        self.numero_orden = self.generar_numero_orden()
        self.estado = estado
        self.valor_total = 0
        self.id_cliente = id_cliente
        self.id_vendedor = id_vendedor
        self.id_bodega_origen = id_bodega_origen
        self.creado_por = creado_por
        self.fecha_entrega_estimada = fecha_entrega_estimada
        self.observaciones = observaciones
    
    def generar_numero_orden(self):
        date_part = datetime.now().strftime('%y%m%d')
        uuid_part = str(uuid.uuid4())[:8].upper()

        return f"ORD-{date_part}-{uuid_part}"