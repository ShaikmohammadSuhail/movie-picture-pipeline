# Build stage
FROM node:18-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# REACT_APP_MOVIE_API_URL is injected at build time via --build-arg
ARG REACT_APP_MOVIE_API_URL=http://localhost:5000
ENV REACT_APP_MOVIE_API_URL=$REACT_APP_MOVIE_API_URL

RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

# Expose on port 3000 to match local development expectations
RUN sed -i 's/listen\s*80;/listen 3000;/' /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
