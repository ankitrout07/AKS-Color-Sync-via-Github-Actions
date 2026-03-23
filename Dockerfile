FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 8081
# Add this to your Dockerfile if you want to force port 8081
ENV PORT=8081
CMD ["node", "app.js"]