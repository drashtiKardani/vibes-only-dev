# flutter_panel

Admin panel for the VibesOnly project.

## Building

To build the staging panel, in the current directory run:

`flutter build web -o ./build/web-staging --dart-define=BASE_URL=https://vo-api.6thsolution.com/api/v1/`

For production panel run:

`flutter build web -o ./build/web-production --dart-define=BASE_URL=https://app.vibesonly.com/api/v1/`

## Deploying

Go to [Vercel panel](https://vercel.com), and deploy from there by:

- Select [Staging panel](https://vercel.com/6thsolution/vibes-only-staging)
  or [Production panel](https://vercel.com/6thsolution/vibes-only).
- Select the branch you want to deploy.
- Click on `...` in front of the commit you want to deploy and select **"Promote to Production"**