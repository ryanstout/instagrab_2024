# rsync to tobias2

rsync -avz --delete --exclude=db/db.sqlite3  --exclude=temp/ --exclude=cache --exclude=images --exclude=README.md --exclude=.git . tobias@tobias2:/Users/tobias/instagrab_ruby/ --progress