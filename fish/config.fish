if status is-interactive
    oh-my-posh init fish --config ~/.config/omp/config.omp.json | source
    set -g fish_term24bit 1
    set -g theme_color_scheme nord
    set -g theme_date_format "+%b %d %r"
    # cd ~
end
