# Thème Oh My Zsh de Keyn : Water Panda

local my_red_color=$'\e[1;38;2;255;150;150m'
local my_green_color=$'\e[1;38;2;150;255;150m'

local folder_color=$'\e[1;38;2;150;255;200m'
local git_status_color=$'\e[1;38;2;255;205;250m'
local git_surround_color=$'\e[1;38;2;150;230;255m'

# 1. Configuration des flèches et croix dynamiques
local ret_status="%(?:%{${my_green_color}%}➜ :%{${my_red_color}%}➜ %s)"
local git_cross="%(?:%{${my_green_color}%}✗ :%{${my_red_color}%}✗ %s)"

# 2. PROMPT principal (à gauche) : Dossier en Turquoise (123) + Thème Zen
PROMPT='${ret_status}🎍 %{${folder_color}%}%c%f $(my_git_info)%{$reset_color%}🎐 ${git_cross}%{$fg_bold[blue]%}$(svn_prompt_info)%{$reset_color%}'

# 3. RPROMPT (à droite) : Torii, Mont Fuji (🗻), numéro de ligne (%!)
local soft_white=$'\e[38;2;235;240;245m'
RPROMPT='%{${soft_white}%}- %! -%{$reset_color%}'

function my_git_info() {
  # ============ TES ICÔNES (à modifier ici) ============
  local icon_clean="⛲"        # tout est propre
  local icon_staged="🍣"      # fichiers ajoutés (git add), prêts à commit
  local icon_modified="🫧"    # fichiers modifiés non ajoutés
  local icon_untracked="🍁"   # nouveaux fichiers non suivis
  local icon_conflict="🚏"    # conflit de merge
  local icon_ahead="⇡"        # commits locaux à pousser
  local icon_behind="⇣"       # commits distants à récupérer

  # 0 = une seule icône (la plus prioritaire), 1 = toutes celles qui s'appliquent
  local show_all=0
  # =====================================================

  local out
  out=$(command git --no-optional-locks status --porcelain=v2 --branch --ignore-submodules=dirty 2>/dev/null) || return

  local line ref="" oid="" ahead=0 behind=0
  local has_conflict=0 has_modified=0 has_untracked=0 has_staged=0

  for line in "${(@f)out}"; do
    case $line in
      '# branch.oid '*)  oid=${line#'# branch.oid '} ;;
      '# branch.head '*) ref=${line#'# branch.head '} ;;
      '# branch.ab '*)
        ahead=${${line#'# branch.ab +'}%% *}
        behind=${line##* -}
        ;;
      'u '*)    has_conflict=1 ;;
      '? '*)    has_untracked=1 ;;
      [12]' '*)
        [[ ${line[3]} != . ]] && has_staged=1     # X : index
        [[ ${line[4]} != . ]] && has_modified=1   # Y : dossier de travail
        ;;
    esac
  done

  # HEAD détachée : on affiche le hash court
  [[ $ref == '(detached)' ]] && ref=${oid[1,7]}

  # Choix de l'icône d'état
  local state=""
  if (( show_all )); then
    (( has_conflict ))  && state+=$icon_conflict
    (( has_modified ))  && state+=$icon_modified
    (( has_untracked )) && state+=$icon_untracked
    (( has_staged ))    && state+=$icon_staged
    [[ -z $state ]] && state=$icon_clean
  else
    if   (( has_conflict ));  then state=$icon_conflict
    elif (( has_modified ));  then state=$icon_modified
    elif (( has_untracked )); then state=$icon_untracked
    elif (( has_staged ));    then state=$icon_staged
    else state=$icon_clean
    fi
  fi

  # Flèches avec nombres (seulement si ≠ 0)
  local sync=""
  (( ahead ))  && sync+=" ${icon_ahead}${ahead}"
  (( behind )) && sync+=" ${icon_behind}${behind}"

  echo "%{${git_surround_color}%}git:(%{${git_status_color}%}${ref}${state}${sync}%{${git_surround_color}%}) %{$reset_color%}"
}

# 4. Style de Git : Branche en Violet/Magenta clair
ZSH_THEME_GIT_PROMPT_PREFIX="%{${git_surround_color}%}git:(%{${git_status_color}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{${git_surround_color}%}) "
ZSH_THEME_GIT_PROMPT_CLEAN="%{${git_surround_color}%}) "

ZSH_PROMPT_BASE_COLOR="%{$fg_bold[blue]%}"
ZSH_THEME_REPO_NAME_COLOR="%{${my_red_color}%}"
