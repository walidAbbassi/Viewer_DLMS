// core/theme/app_icons.dart
//
// Icônes adaptées au domaine DLMS/COSEM smart metering (compteur électrique).
// Objectif : remplacer les icônes génériques par un vocabulaire cohérent et
// reconnaissable pour un métier "smart metering". Une seule source d'icônes,
// mappée par clé de fonctionnalité (FeatureKeys).

import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  // --- Marque / global -------------------------------------------------
  static const meter          = Icons.electric_meter;      // compteur (marque, chip statut)
  static const connected      = Icons.electrical_services; // liaison série active
  static const disconnected   = Icons.power_off;           // pas de liaison
  static const disconnect     = Icons.link_off;            // action déconnexion
  static const meterConnexion = Icons.home;                 // item nav "Meter Connexion"

  // --- Meter Connexion -------------------------------------------------
  static const connection     = Icons.settings_input_component; // setup connexion
  static const association     = Icons.vpn_key;             // DLMS association / auth
  static const dictionary      = Icons.menu_book;           // product dictionary
  static const simulation      = Icons.science;             // mode simulation

  // --- Identification --------------------------------------------------
  static const deviceId        = Icons.badge;               // identité compteur
  static const firmwareVersion = Icons.memory;              // versions firmware / metrology

  // --- Clock -----------------------------------------------------------
  static const clock           = Icons.schedule;            // date/heure
  static const daylightSavings = Icons.wb_twilight;         // heure d'été/hiver
  static const timezone        = Icons.public;              // fuseau

  // --- Tariff management ----------------------------------------------
  static const calendar        = Icons.calendar_month;      // calendrier tarifaire
  static const tariff          = Icons.sell;                // tarif / TOU

  // --- Load profiles ---------------------------------------------------
  static const loadProfile     = Icons.show_chart;          // courbe de charge
  static const profileStatus   = Icons.fact_check;          // statut de profil
  static const pqProfile       = Icons.monitor_heart;       // power-quality profile

  // --- Event logs ------------------------------------------------------
  static const eventLog        = Icons.receipt_long;        // journaux d'événements
  static const fraud           = Icons.gpp_maybe;           // détection de fraude / tamper
  static const powerFailure    = Icons.power_off;           // coupure secteur
  static const powerQualityLog = Icons.monitor_heart;       // qualité réseau
  static const communicationLog= Icons.sync_alt;            // log communication
  static const disconnector    = Icons.toggle_on;           // organe de coupure

  // --- Quality (grandeurs électriques) --------------------------------
  static const qualityParams   = Icons.show_chart;
  static const sag             = Icons.south_east;          // creux de tension
  static const swell           = Icons.north_east;          // surtension
  static const thd             = Icons.ssid_chart;          // distorsion harmonique
  static const neutral         = Icons.timeline;            // neutre
  static const overcurrent     = Icons.bolt;                // surintensité
  static const powerFactor     = Icons.speed;               // facteur de puissance
  static const minMax          = Icons.compare_arrows;
  static const abnormalState   = Icons.warning_amber;

  // --- Electricity objects --------------------------------------------
  static const energyRegister  = Icons.electric_meter;      // registres d'énergie
  static const ctvt            = Icons.change_circle;       // CT/VT (transformateurs)
  static const instant         = Icons.flash_on;            // valeurs instantanées
  static const average         = Icons.ssid_chart;          // moyennes

  // --- Firmware / réseau ----------------------------------------------
  static const firmwareUpgrade = Icons.system_update_alt;   // OTA
  static const modem           = Icons.sync_alt;            // modem / P2P
  static const sim             = Icons.sim_card;            // SIM
  static const mobileNetworkId = Icons.sim_card_outlined;   // ID réseau mobile
  static const tcpUdp          = Icons.lan;                 // TCP/UDP

  // --- Push setups -------------------------------------------------------
  static const pushSetupServer = Icons.campaign;            // serveur push
  static const pushSetup       = Icons.notifications_active;// push setup
  static const pushAction      = Icons.play_circle_outline; // push action
  static const scriptTable     = Icons.code;                // script table
  static const pushSelective   = Icons.filter_list;         // push selective
  static const pushRecovery    = Icons.restore;             // push recovery

  // --- Outils ----------------------------------------------------------
  static const manualDlms      = Icons.terminal;            // GET/SET/ACTION brut
  static const rawFrame        = Icons.data_object;         // trame hex/XML
  static const configuration   = Icons.settings;            // configuration
  static const superManual     = Icons.library_books;       // super manual tool
  static const exportTemplates = Icons.layers;              // export templates
  static const dlmsTranslator  = Icons.translate;           // DLMS translator

  // --- Actions génériques ---------------------------------------------
  static const read            = Icons.download_rounded;    // Read (secondaire)
  static const write           = Icons.upload_rounded;      // Write (primaire)
  static const refresh         = Icons.refresh;
  static const export          = Icons.ios_share;
  static const copy            = Icons.content_copy;
  static const connect         = Icons.play_circle_fill;    // action Connect (primaire)
  static const help            = Icons.help_outline;        // aide
  static const logs            = Icons.list_alt;            // panneau de logs (distinct de manualDlms)
}
