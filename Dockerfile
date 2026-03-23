FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 8080
# Add this to your Dockerfile if you want to force port 8080
ENV PORT=8080
CMD ["node", "app.js"]