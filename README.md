testing Claude.ai vibe coding for an idea of indexing file with/without api.

# Indexarr

**Indexarr** est un outil d'indexation de bibliotheque multimedia locale. A partir d'une simple liste de fichiers (CSV, TXT ou JSON), il identifie automatiquement chaque film et serie via l'API OMDB, enrichit les metadonnees (titre officiel, annee, affiche, IMDb ID) et produit une base exportable propre et normalisee.

L'application est un fichier HTML unique qui tourne entierement dans le navigateur. Aucun serveur, aucune installation, aucune base de donnees externe.

---

## Pourquoi Indexarr ?

Les bibliotheques multimedia locales accumulent des milliers de fichiers aux noms heterogenes :

```
The.Dark.Knight.2008.1080p.BluRay.x265-GROUP.mkv
Chappie.(2015).MULTI.HDR.mkv
Breaking.Bad.S01E01.720p.mkv
Princesse Mononoke 1997 VOSTFR.mkv
```

Ces noms sont lisibles par un humain mais inutilisables tels quels par un systeme de catalogue ou de partage. Indexarr resout ce probleme : il parse chaque nom, interroge OMDB, et produit une entree normalisee avec un IMDb ID fiable, un titre officiel, une annee et une affiche.

Le resultat est un fichier JSON ou CSV exploitable directement par Sonarr, Radarr, ou n'importe quelle plateforme de gestion de mediatheque.

---

## Fonctionnement

```
Fichier CSV / TXT / JSON
        |
        v
  [Parsing des noms]          -- extrait titre, annee, type (film/serie)
        |
        v
  [Appel OMDB]                -- recherche par titre + annee + type
        |
        v
  [Score de similarite]       -- compare titre parse vs titre OMDB
        |
    +---+---+
    |       |
Score >= 80  Score < 80  Aucun resultat
    |       |                 |
 validated  pending       quarantine
    |       |                 |
    |       +--------+--------+
    |                |
    |         [Correction manuelle]   -- modal de recherche integre
    |                |
    +----------------+
             |
             v
     [Export JSON / CSV]
```

**Les trois statuts de sortie :**

| Statut | Condition | Signification |
|---|---|---|
| `validated` | Score >= seuil (defaut 80) | Correspondance fiable, aucune action requise |
| `pending` | Score < seuil | Correspondance incertaine, verification conseilllee |
| `quarantine` | Aucun resultat OMDB | Titre non reconnu, correction ou suppression |

---

## Demarrage rapide

**Prerequis :** un navigateur moderne (Chrome, Firefox, Edge, Safari) et une cle API OMDB gratuite ([omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx)).

**1. Generer la liste de fichiers**

```powershell
# Windows / PowerShell
Get-ChildItem -Path "D:\Films" -Recurse -Include *.mkv,*.mp4,*.avi |
  Select-Object -ExpandProperty Name |
  Out-File "ma-bibliotheque.txt" -Encoding UTF8
```

**2. Ouvrir l'application**

```
double-clic sur indexarr-app.html
```

> En cas de blocage CORS en mode `file://` :  
> `python -m http.server 8080` puis `http://localhost:8080/indexarr-app.html`

**3. Configurer et lancer**

- Saisir la cle API OMDB dans la sidebar
- Glisser le fichier TXT/CSV/JSON dans la zone d'upload
- Le scan demarre automatiquement

**4. Corriger et exporter**

- Traiter les entrees `pending` et `quarantine` via le modal de verification
- Cliquer sur **Export JSON** (sauvegarde complete) ou **Export CSV** (integration externe)

---

## Fichiers du projet

| Fichier | Description |
|---|---|
| `indexarr-app.html` | Application complete -- le seul fichier necessaire |
| `indexarr-db.json` | Exemple de base exportee (films de demonstration) |

---

## Formats acceptes en entree

| Format | Description |
|---|---|
| `.txt` | Un nom de fichier ou chemin par ligne |
| `.csv` | Premiere colonne = nom de fichier (separateurs `,` `;` ou tabulation) |
| `.json` | Tableau de chaines, ou objet avec valeurs de type chaine |
| `.json` (DB Indexarr) | Re-import d'une base exportee -- merge sans doublon |

---

## Stack technique

| Composant | Detail |
|---|---|
| Runtime | Navigateur moderne |
| Langage | HTML5 + CSS3 + JavaScript ES2022 (vanilla, sans framework) |
| API externe | OMDB API -- 1 000 req/jour gratuit |
| Persistance | `localStorage` du navigateur (cle : `indexarr_db`) |
| Deploiement | Fichier HTML statique autonome |

---

## Limites connues

- Le compteur API se remet a zero a chaque rechargement de page (non persiste)
- `localStorage` limite a ~5 Mo -- pour les tres grandes bibliotheques (> 10 000 titres), utiliser l'export JSON comme stockage principal
- `tvdbId` non alimente : OMDB ne fournit pas les identifiants TVDB
- La recherche manuelle est limitee a 8 resultats par requete OMDB

---

## Liens

- [Guide d'utilisation (Wiki)](../../wiki/Flux-utilisateur)
- [Documentation technique](../../wiki/Documentation-Technique.md)
- [Cle API OMDB gratuite](https://www.omdbapi.com/apikey.aspx)
