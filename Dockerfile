FROM node:20 AS dependencies

WORKDIR /usr/www/app

COPY package.json package-lock.json ./

RUN npm install

FROM dependencies AS build

WORKDIR /usr/www/app

COPY . .
COPY --from=dependencies /usr/www/app/node_modules ./node_modules

RUN npm run build
RUN npm prune --production

FROM node:20-alpine3.19 AS deploy

WORKDIR /usr/www/app

RUN npm i -g prisma

COPY --from=build /usr/www/app/dist ./dist
COPY --from=build /usr/www/app/node_modules ./node_modules
COPY --from=build /usr/www/app/package.json ./package.json
COPY --from=build /usr/www/app/prisma ./prisma

ENV DATABASE_URL="file:./db.sqlite"
ENV API_BASE_URL="http://localhost:3333"
ENV PORT=3333
ENV POSTGRES_USER='admin'
ENV POSTGRES_PASSWORD='admin'
ENV POSTGRES_DB='nlw-unite'

RUN npx prisma generate

EXPOSE 3333

CMD ["npm", "start"]