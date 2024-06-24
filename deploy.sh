# rsync to tobias2

rsync -avz --delete --exclude=node_modules --exclude=.venv . tobias@tobias2:/Users/tobias/instagrab_ruby/ --progress