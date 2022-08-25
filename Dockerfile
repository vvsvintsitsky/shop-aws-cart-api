### Build

FROM node:14-alpine As build

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY tsconfig*.json nest-cli.json ./
COPY ./src ./src

RUN npm run build && npm prune --production

### Production

FROM gcr.io/distroless/nodejs:14

ARG WORKDIR="/usr/src/app"

WORKDIR ${WORKDIR}

ENV NODE_ENV production

COPY package*.json ./
COPY --from=build ${WORKDIR}/node_modules/ ./node_modules
COPY --from=build ${WORKDIR}/dist ./dist

EXPOSE 4000

CMD [ "dist/main.js" ]