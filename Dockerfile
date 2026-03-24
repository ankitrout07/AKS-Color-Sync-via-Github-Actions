FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
ENV PORT=3000
EXPOSE 3000
CMD ["node", "app.js"]