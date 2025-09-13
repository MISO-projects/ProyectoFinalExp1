
GOOGLE_CLOUD_PROJECT=$(gcloud config get project)

# Service Account configuration
SERVICE_ACCOUNT_NAME="orders-service"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"

# Create Service Account if it doesn't exist
echo "🔐 Creating/checking Service Account..."
if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL --quiet 2>/dev/null; then
    echo "Creating Service Account: $SERVICE_ACCOUNT_EMAIL"
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="Orders Service Account" \
        --description="Service account for processing orders"
else
    echo "Service Account already exists: $SERVICE_ACCOUNT_EMAIL"
fi

echo "🔑 Granting Pub/Sub permissions..."
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/pubsub.publisher"

# Create topics if they don't exist
echo "🔐 Creating/checking Topics..."
if ! gcloud pubsub topics describe create-order-command --quiet 2>/dev/null; then
    echo "Creating Topic: create-order-command"
    gcloud pubsub topics create create-order-command
else
    echo "Topic already exists: create-order-command"
fi

if ! gcloud pubsub topics describe order-created --quiet 2>/dev/null; then
    echo "Creating Topic: order-created"
    gcloud pubsub topics create order-created
else
    echo "Topic already exists: order-created"
fi

# Grant permissions to service accounts
# echo "🔐 Granting permissions to service accounts..."
# gcloud pubsub topics add-iam-policy-binding create-order-command --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL --role=roles/pubsub.publisher
# gcloud pubsub topics add-iam-policy-binding order-created --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL --role=roles/pubsub.publisher

# # Create subscriptions if they don't exist
# gcloud pubsub subscriptions create create-order-command-subscription --topic create-order-command
# gcloud pubsub subscriptions create order-created-subscription --topic order-created

# # Create service accounts if they don't exist
# gcloud iam service-accounts create pubsub-service-account
# gcloud iam service-accounts create order-service-account

# # Grant permissions to service accounts
# gcloud pubsub topics add-iam-policy-binding create-order-command --member=serviceAccount:pubsub-service-account@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/pubsub.publisher
# gcloud pubsub topics add-iam-policy-binding order-created --member=serviceAccount:order-service-account@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/pubsub.publisher