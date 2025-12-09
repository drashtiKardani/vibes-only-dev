#Stage 1 - Install dependencies and build the app
FROM cirrusci/flutter:3.3.0 AS build-env

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
WORKDIR /app/
RUN flutter pub get

# Build the app
RUN flutter build web

# Stage 2 - Create the run-time image
FROM python:3.9.16-alpine
RUN pip install Flask
RUN pip install requests
RUN pip install gunicorn
COPY ./flask_server .
RUN mkdir templates
COPY --from=build-env /app/build/web ./templates
CMD ["python", "app.py"]
