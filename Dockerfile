### Build

FROM node:18-alpine As build

USER node

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node tsconfig*.json nest-cli.json ./
COPY --chown=node:node ./src ./src

RUN npm run build

### Production

FROM node:16-alpine

USER node

WORKDIR /usr/src/app

ENV NODE_ENV production

COPY --chown=node:node package*.json ./

RUN npm ci --only=production

COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]