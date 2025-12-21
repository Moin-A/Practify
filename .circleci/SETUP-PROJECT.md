# Setting Up CircleCI for Practify Organization

This guide will help you connect your GitHub repository to CircleCI and ensure pipelines run when you push code.

## Step 1: Add Project to CircleCI

1. **Go to CircleCI Dashboard**: https://app.circleci.com
2. **Select your organization**: Make sure you're in the "practify" organization
3. **Click "Add Project"** or go to **Projects** in the sidebar
4. **Find your repository**: Look for `Moin-A/Practify` in the list
5. **Click "Set Up Project"** next to your repository

## Step 2: Configure Project Settings

1. **Select configuration method**:
   - Choose "Use an existing config" (since we already have `.circleci/config.yml`)
   - Or let CircleCI detect it automatically

2. **Select branch**: Choose `main` (or your default branch)

3. **Click "Set Up Project"**

## Step 3: Update Resource Class (For Self-Hosted Runner)

If you're using a self-hosted runner, update `.circleci/config.yml`:

1. In CircleCI, go to **Organization Settings** → **Self-Hosted Runners**
2. Find your resource class (format: `self-hosted/practify/your-resource-class`)
3. Update the config file:
   ```yaml
   resource_class: self-hosted/practify/your-resource-class
   ```

## Step 4: Set Environment Variables

Go to **Project Settings** → **Environment Variables** and add:

- `DOCKER_USERNAME` = `moindev`
- `DOCKER_PASSWORD` = Your Docker Hub access token

## Step 5: Test the Pipeline

1. **Push your code**:
   ```bash
   git add .
   git commit -m "Add CircleCI configuration"
   git push origin main
   ```

2. **Check CircleCI Dashboard**: 
   - Go to your project: `Moin-A/Practify`
   - You should see a new pipeline running

## Step 6: Verify Pipeline Runs

- Pipeline should trigger automatically on every push to `main`
- You can also trigger manually from the CircleCI dashboard
- Check the "Workflows" tab to see pipeline status

## Troubleshooting

### Pipeline not running?
- Check that the project is added to CircleCI
- Verify `.circleci/config.yml` is in your repository
- Check that you're pushing to the correct branch
- Look for errors in CircleCI dashboard

### Self-hosted runner not picking up jobs?
- Verify runner is running: `sudo circleci-runner status`
- Check resource class matches in config
- Ensure runner is registered to the correct organization

### Need to use cloud runners instead?
- Comment out the `executor` section in config.yml
- Uncomment the `docker` section
- The pipeline will use CircleCI's cloud infrastructure

