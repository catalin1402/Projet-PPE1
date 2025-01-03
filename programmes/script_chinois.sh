#!/usr/bin/bash

# Vérification du nombre d'arguments
if [ $# -ne 1 ]; then
    echo "Erreur : Ce script nécessite exactement un argument (le fichier des URLs)." >&2
    exit 1
fi

fichier=$1  # Fichier contenant les URLs
aspirations="/home/hxt/Projet-PPE1/aspirations/html_ch"
dumps="/home/hxt/Projet-PPE1/dumps-text/dump_ch"
output_html="/home/hxt/Projet-PPE1/tableaux/tableau_ch.html"
mot="开放"
n=1  # Initialisation du compteur de lignes

# Initialisation du fichier HTML
echo "<!DOCTYPE html>" > "$output_html"
echo "<html>" >> "$output_html"
echo "<head><meta charset=\"UTF-8\"><title>Résultats des URLs</title>" >> "$output_html"
echo "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.3/css/bulma.min.css\">" >> "$output_html"
echo "</head><body><div class=\"container\">" >> "$output_html"
echo "<h1 class=\"title\">Résultats des URLs</h1>" >> "$output_html"
echo "<table class=\"table is-bordered is-striped is-fullwidth\">" >> "$output_html"
echo "<thead><tr><th>ligne</th><th>URL</th><th>Code HTTP</th><th>Encodage</th><th>DumpText</th><th>HTML</th><th>Occurrences</th></tr></thead>" >> "$output_html"
echo "<tbody>" >> "$output_html"

# Lecture ligne par ligne du fichier contenant les URLs
while read -r line; do
    # Récupération du code HTTP et du type de contenu
    code=$(curl -s -I -L -w "%{http_code}" -o /dev/null "$line")
    encoding=$(curl -o /dev/null -s -I -L -w "%{content_type}" "$line" | grep -Po "charset=\S+" | cut -d "=" -f2 | tr -d "\r\n")

    # Vérification du code HTTP
    if [ "$code" -eq 200 ]; then
	aspiration_file="$aspirations/page_${n}.html"
	dump_file="$dumps/dump_${n}.txt"

	curl -s -L "$line" -o "$aspiration_file"

	lynx -dump -nolist "$line" > "$dump_file"

	compte=$(grep -o "$mot" "$dump_file" | wc -l)

	 # Ajouter une ligne au tableau avec des liens HTML
        echo "<tr>" >> "$output_html"
        echo "<td>$n</td><td><a href=\"$line\" target=\"_blank\">$line</a></td><td>$code</td><td>${encoding:-N/A}</td>" >> "$output_html"
        echo "<td><a href=\"$dump_file\" target=\"_blank\">text</a></td><td><a href=\"$aspiration_file\" target=\"_blank\">html</a></td>" >> "$output_html"
        echo "<td>$compte</td></tr>" >> "$output_html"
    else
        # URL invalide
        echo "Erreur : $line renvoie un code HTTP $code. Ignorée." >&2
        echo "<tr>" >> "$output_html"
        echo "<td>$n</td><td><a href=\"$line\" target=\"_blank\">$line</a></td><td>$code</td><td>N/A</td>" >> "$output_html"
        echo "<td>N/A</td><td>N/A</td><td>0</td></tr>" >> "$output_html"
    fi

    n=$((n + 1))  # compteur
done < "$fichier"

# Finalisation du fichier HTML
echo "</tbody></table></div></body></html>" >> "$output_html"
echo "Résultats enregistrés dans $output_html."

