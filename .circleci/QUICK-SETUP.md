# Quick Setup: Connect Practify to CircleCI

## ✅ Steps to Enable Pipeline on Push

### 1. Add Project in CircleCI (5 minutes)

1. Go to: https://app.circleci.com/projects
2. **Switch to "practify" organization** (top left dropdown)
3. Click **"Add Project"** button
4. Find **"Moin-A/Practify"** in the list
5. Click **"Set Up Project"**
6. Select **"Use existing config"** (we have `.circleci/config.yml`)
7. Click **"Set Up Project"**

### 2. Update Config for Your Organization

If using self-hosted runner, update the resource class in `.circleci/config.yml`:

```yaml
resource_class: self-hosted/practify/your-resource-class
```

Replace `your-resource-class` with your actual resource class name.

### 3. Set Environment Variables

In CircleCI project settings:
- **Project Settings** → **Environment Variables**
- Add:
  - `DOCKER_USERNAME` = `moindev`
  - `DOCKER_PASSWORD` = (your Docker Hub token)

### 4. Test It!

```bash
# Make sure config is committed
git add .circleci/config.yml docker-compose.test.yml
git commit -m "Add CircleCI configuration"
git push origin main
```

### 5. Verify Pipeline Runs

- Go to CircleCI dashboard
- Click on your project: **Moin-A/Practify**
- You should see a pipeline running!

## 🔧 Using Cloud Runners Instead?

If you want to use CircleCI's cloud runners (easier to start):

1. Comment out the `executor` section in `.circleci/config.yml`
2. Uncomment the `docker` section
3. The pipeline will use CircleCI's cloud infrastructure automatically

## 📋 Checklist

- [ ] Project added to CircleCI
- [ ] Organization set to "practify"
- [ ] Config file committed to repo
- [ ] Environment variables set
- [ ] Pushed code to trigger pipeline
- [ ] Pipeline appears in dashboard

