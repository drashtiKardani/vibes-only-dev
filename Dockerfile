#Stage 1 - Install dependencies and build the app
FROM cirrusci/flutter:3.7.3 AS build-env

# Install flutter dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip \
    libgconf-2-4 gdb libstdc++6 libglu1-mesa \
    fonts-droid-fallback lib32stdc++6 python3 && \ 
    apt-get clean

# Run flutter doctor
RUN flutter doctor -v

# Copy files to container and run preprocessors
RUN mkdir /app/
COPY . /app/
WORKDIR /app/flutter_common
RUN dart pub get && \ 
    dart pub run build_runner build
WORKDIR /app/flutter
RUN flutter pub get && \
    flutter pub run intl_utils:generate && \
    flutter pub run build_runner build
WORKDIR /app/flutter_panel
RUN flutter pub get && \
    flutter pub run intl_utils:generate && \
    flutter pub run build_runner build

# Build the app
ARG BASE_URL=https://app.vibesonly.com/api/v1/
RUN flutter build web --dart-define=BASE_URL=$BASE_URL --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/flutter_panel/build/web /usr/share/nginx/html
