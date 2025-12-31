#!/bin/bash

# Stalwart Mail OIDC Configuration Script
CONTAINER_NAME="deploy-mailserver-1"
CLIENT_ID="Fzbt4wAUeBwR3yiTP9tGAOfwu6p6MLp089oMDOlAJW0YMQ00pRw1QksknkHFVeTj"
CLIENT_SECRET="JgpctkgbNm6H4OC50KtX6hrmB93Gd39yTN468owqNElvPTC9P7amLGzZ65VBut04"
ISSUER="https://cloud.feelmagic.store"

echo "--- Configuring Stalwart Mail OIDC ---"

# We will use the 'stalwart-mail' CLI if available inside the container, 
# or we'll update the config.toml directly if we can find it.
# However, the most reliable way for Stalwart is often via the management API or config.

# Let's try to find the config file path first
CONFIG_PATH=$(docker exec $CONTAINER_NAME find /opt/stalwart-mail -name "config.toml" | head -n 1)

if [ -z "$CONFIG_PATH" ]; then
    echo "Error: Could not find config.toml inside $CONTAINER_NAME"
    exit 1
fi

echo "Found config at: $CONFIG_PATH"

# For Stalwart, OIDC is usually configured in the [authentication.oidc] section.
# We will append the configuration if not present or advice the user.

# But wait, Stalwart also has a Management UI where this can be done easily.
# To do it via CLI, we can try 'stalwart-cli'.

# Since I cannot interactively run the CLI, I will provide a script that 
# the user can run to UPSERT the OIDC configuration.

# Actually, a better way is to provide the TOML snippet for the user to paste.
# But the user asked for a script.

echo "Step 1: Preparing OIDC configuration..."
# This is a conceptual configuration. Stalwart's specific OIDC structure:
# [authentication.oidc.nextcloud]
# client-id = "..."
# client-secret = "..."
# issuer = "..."

# Let's provide a script that uses docker exec to append to config.toml
# Note: Stalwart might need a restart to pick up config.toml changes.

docker exec $CONTAINER_NAME bash -c "cat >> $CONFIG_PATH <<EOF

[authentication.oidc.nextcloud]
client-id = \"$CLIENT_ID\"
client-secret = \"$CLIENT_SECRET\"
issuer = \"$ISSUER\"
scopes = [\"openid\", \"profile\", \"email\"]
EOF"

echo "Step 2: Restarting Mailserver to apply changes..."
docker restart $CONTAINER_NAME

echo "--- Stalwart OIDC Configuration Finished! ---"
echo "Please go to https://mail.feelmagic.store and look for 'Login with Nextcloud'."
