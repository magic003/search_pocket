# tmux configuration for this project
source-file ~/.tmux.conf
new-session -s search_pocket -n editor -d
send-keys -t search_pocket 'cd ~/workspace/search_pocket' C-m
split-window -h -t search_pocket
resize-pane -t search_pocket:1.1
send-keys -t search_pocket:1.2 'cd ~/workspace/search_pocket' C-m
select-pane -t search_pocket:1.1
new-window -n console -t search_pocket
send-keys -t search_pocket:2 'cd ~/workspace/search_pocket && rerun --pattern "**/*.rb" "ruby search_pocket_app.rb"' C-m
select-window -t search_pocket:1
