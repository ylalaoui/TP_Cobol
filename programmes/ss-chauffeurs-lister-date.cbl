       program-id. ss-chauffeurs-lister-date.

       input-output section.
       file-control.
           select FAffectations assign to "../ext/Affectation.dat"
               organization is indexed
               access mode is dynamic
                   record key is num-affect
                   alternate key is num-chauf with duplicates
                   alternate key is num-bus with duplicates
               status FAffectStatus.

           select FChaufNouv assign to "../ext/ChaufNouv.dat"
               organization is indexed
               access mode is dynamic
                   record key is numChaufN
                   alternate record key is nomN with duplicates
               status FChaufNouvStatus.

       data division.
       file section.
       FD FAffectations.
       01 enr-affectation.
           02 num-affect   pic 9(4).
           02 num-chauf    pic 9(4).
           02 num-bus      pic 9(4).
           02 date-debut   pic 9(8).
           02 date-fin     pic 9(8).

       FD FChaufNouv.
       01 enr-chauffeur.
           02 numChaufN    pic 9(4).
           02 nomN         pic x(30).
           02 prenomN      pic x(30).
           02 datePermisN  pic 9(8).


       working-storage section.
       01 FAffectStatus         pic x(2).
       01 FChaufNouvStatus      pic x(2).
       01 date-dispo            pic 9(8).

       01 i                     pic 99.
       01 j                     pic 99.
       01 quitter               pic x.
       01 fin-affect-fichier    pic x.
       01 fin-chauff-fichier    pic x.
       01 saisie                pic 9999/99/99.

       01 chauffeur-disponible  pic 9 value 1.
       01 aucun-resultat        pic 9.

       screen section.

      *----- Titres -----
       01 a-plg-titre-global.
           02 blank screen.
           02 line 1 col 10 value '- Liste des chauffeurs'
           &' disponibles -'.

      *----- Recherche -----
       01 s-plg-rechercher-date.
           02 line 3 col 2 value 'Choix de la date: '.
           02 s-date-dispo pic 9999/99/99 to date-dispo.

      *------ Structure d'affichage de donn�e -------
       01 a-plg-titre-colonne.
           02 line 5 col 2 value 'Id'.
           02 line 5 col 8 value 'Nom'.
           02 line 5 col 39 value 'Prenom'.
           02 line 5 col 69 value 'Date permis'.
       01 a-plg-separateur.
           02 line j col 1 value
           '----------------------------------------------------------'
               &'---------------------'.

       01 a-plg-chauffeur-data.
           02 a-numChaufN line i col 2    pic 9(4) from numChaufN.
           02 a-nomN line i col 8         pic x(30) from nomN.
           02 a-prenomN line i col 39     pic x(30) from prenomN.
           02 a-date-permis line i col 69 pic x(30) from datePermisN.

      *------ Messages pour l'utilisateur ------
       01 a-plg-message-continuer.
           02 line 20 col 1 value 'Appuyez sur ENTREE pour continuer.'.
       01 a-error-Affect-file-open.
           02 blank screen.
           02 line 3 col 2 value 'Erreur Affectations.dat - status: '.
           02 a-FAffectStatus line 3 col 26 pic 99 from FAffectStatus.
       01 a-error-Chauf-file-open.
           02 blank screen.
           02 line 3 col 2 value 'Erreur ChaufNouv.dat - status: '.
           02 a-FChaufNouvStatus line 3 col 24 pic 99 from
           FChaufNouvStatus.
       01 a-plg-aucun-resultat.
           02 line 6 value 'Aucun chauffeur de disponible � cette date'.

      *#################################################################
      *######################### PROGRAMME #############################
      *#################################################################

       procedure division.

       open input FChaufNouv
       open input FAffectations

       if FChaufNouvStatus not = '00' then
           display a-error-Chauf-file-open
       else if FAffectStatus not = '00' then
           display a-error-Affect-file-open
       else
           move 1 to aucun-resultat
           move 7 to i
           move 0 to numChaufN

           display a-plg-titre-global
           move 04 to j
           display a-plg-separateur
           display s-plg-rechercher-date
           accept s-plg-rechercher-date
           perform ITERE-CHAUFFEURS

           if aucun-resultat = 1 then
               display a-plg-aucun-resultat
           else
            display a-plg-titre-colonne
            move 6 to j
            display a-plg-separateur
           end-if

           display a-plg-message-continuer
           stop ' '

       close FAffectations
       close FChaufNouv

       goback
       .

      *#################################################################

       ITERE-CHAUFFEURS.
           move 0 to fin-chauff-fichier
           move 0 to numChaufN
           start FChaufNouv key >= numChaufN

           perform with test after until (fin-chauff-fichier = 1)
               read FChaufNouv next
                   at end
                       move 1 to fin-chauff-fichier
                   not at end
                       perform ITERE-AFFECTATIONS
                       if chauffeur-disponible = 1 then
                           display a-plg-chauffeur-data
                           compute i = i + 1
                           move 0 to aucun-resultat
                       end-if
               end-read
           end-perform
       .

       ITERE-AFFECTATIONS.
           move 1 to chauffeur-disponible
           move 0 to fin-affect-fichier
           move NumChaufN to num-chauf
           start Faffectations key = num-chauf

           if FAffectStatus = '00' then
               perform with test after until (fin-affect-fichier = 1)
                   read FAffectations next
                       at end
                           move 1 to fin-affect-fichier
                       not at end
                           if ( NumChaufN = num-chauf
                               and date-dispo > date-debut
                               and date-dispo < date-fin ) then
                                   move 0 to chauffeur-disponible
                           else
                               move 1 TO fin-affect-fichier
                           end-if

                   end-read
               end-perform
           end-if
       .

       end program ss-chauffeurs-lister-date.
