GOOGLE_CLOUD_PROJECT=$(gcloud config get project)
SERVICE_ACCOUNT_NAME="orders-service"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"

# Create subscription for order-command-handler
ORDER_COMMAND_HANDLER_URL=$(gcloud run services describe order-command-handler --platform managed --region us-central1 --format="value(status.address.url)")
gcloud pubsub subscriptions create create-order-command-sub \
  --topic create-order-command \
  --push-endpoint=$ORDER_COMMAND_HANDLER_URL \
  --push-auth-service-account=$SERVICE_ACCOUNT_EMAIL \
  --min-retry-delay=10 \
  --max-retry-delay=600

# Create subscription for order-projection-handler
ORDER_PROJECTION_HANDLER_URL=$(gcloud run services describe order-projection-handler --platform managed --region us-central1 --format="value(status.address.url)")
gcloud pubsub subscriptions create order-created-sub \
  --topic order-created \
  --push-endpoint=$ORDER_PROJECTION_HANDLER_URL \
  --push-auth-service-account=$SERVICE_ACCOUNT_EMAIL \
  --min-retry-delay=10 \
  --max-retry-delay=600