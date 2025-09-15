module.exports = {
  content: [
    "../$DJANGO_PROJECT_NAME/apps/**/templates/**/*.{html,py,js}",
    "../$DJANGO_PROJECT_NAME/**/templates/**/*.{html,py,js}",
    "../$DJANGO_PROJECT_NAME/static/**/*.{js}",
  ],
  media: false,
};