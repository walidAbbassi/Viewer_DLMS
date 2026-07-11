/// Widget key string constants used as [Key] identifiers for UI automation.
///
/// Usage in widgets:
///   key: const Key(ConnexionKeys.usernameField)
///
/// Usage in tests:
///   find.byKey(const Key(ConnexionKeys.usernameField))

// ─────────────────────────────────────────────────────────────────────────────
// Connexion page
// ─────────────────────────────────────────────────────────────────────────────
abstract class ConnexionKeys {
  static const String usernameField = 'connexion_username_field';
  static const String passwordField = 'connexion_password_field';
  static const String passwordVisibilityBtn =
      'connexion_password_visibility_btn';
  static const String signinBtn = 'connexion_signin_btn';
  static const String rememberChk = 'connexion_remember_chk';
  static const String changePasswordBtn = 'connexion_change_password_btn';
  static const String importLicenseBtn = 'connexion_import_license_btn';
  static const String changePwdOkBtn = 'connexion_change_pwd_ok_btn';
  static const String changePwdCloseBtn = 'connexion_change_pwd_close_btn';
  static const String themeToggleBtn = 'connexion_theme_toggle_btn';
  static const String languageBtn = 'connexion_language_btn';
  static const String helpBtn = 'connexion_help_btn';
}

// ─────────────────────────────────────────────────────────────────────────────
// Average page
// ─────────────────────────────────────────────────────────────────────────────
abstract class AverageKeys {
  static const String dismissErrorBtn = 'average_dismiss_error_btn';
  static const String registerDropdown = 'average_register_dropdown';
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar Profiles page
// ─────────────────────────────────────────────────────────────────────────────
abstract class CalendarProfilesKeys {
  // ── Active tab navigation
  static const String activeBackAllMonthsBtn =
      'calendar_active_back_all_months_btn';
  static const String navPrevMonthBtn = 'calendar_nav_prev_month_btn';
  static const String navMonthDropdown = 'calendar_nav_month_dropdown';
  static const String navYearDropdown = 'calendar_nav_year_dropdown';
  static const String navTodayBtn = 'calendar_nav_today_btn';
  static const String navNextMonthBtn = 'calendar_nav_next_month_btn';

  // ── Yearly overview navigation
  static const String yearlyPrevYearBtn = 'calendar_yearly_prev_year_btn';
  static const String yearlyNavYearDropdown =
      'calendar_yearly_nav_year_dropdown';
  static const String yearlyNextYearBtn = 'calendar_yearly_next_year_btn';
  static const String yearlyNavTodayBtn = 'calendar_yearly_nav_today_btn';

  // ── Status bar
  static const String statusSyncBtn = 'calendar_status_sync_btn';

  // ── Passive tab
  static const String passiveBackAllMonthsBtn =
      'calendar_passive_back_all_months_btn';
  static const String passiveReadBtn = 'calendar_passive_read_btn';
  static const String passiveWriteBtn = 'calendar_passive_write_btn';
  static const String passiveActivateBtn = 'calendar_passive_activate_btn';

  // ── Day profiles
  static const String dayProfileAddBtn = 'calendar_day_profile_add_btn';
  static const String dayProfileNameField = 'calendar_day_profile_name_field';
  static const String dayProfileAddSlotBtn =
      'calendar_day_profile_add_slot_btn';
  static const String dayProfilesReadBtn = 'calendar_day_profiles_read_btn';
  static const String dayProfilesWriteBtn = 'calendar_day_profiles_write_btn';
  static const String dayProfileDeleteBtn = 'calendar_day_profile_delete_btn';

  // ── Week profiles
  static const String weekProfileAddBtn = 'calendar_week_profile_add_btn';
  static const String weekProfilesReadBtn = 'calendar_week_profiles_read_btn';
  static const String weekProfilesWriteBtn = 'calendar_week_profiles_write_btn';
  static const String weekProfileEditorCloseBtn =
      'calendar_week_profile_editor_close_btn';
  static const String weekProfileEditorDeleteBtn =
      'calendar_week_profile_editor_delete_btn';
  static const String weekProfileEditorCancelBtn =
      'calendar_week_profile_editor_cancel_btn';

  // ── Season profiles
  static const String seasonProfileAddBtn = 'calendar_season_profile_add_btn';
  static const String seasonProfilesReadBtn =
      'calendar_season_profiles_read_btn';
  static const String seasonProfilesWriteBtn =
      'calendar_season_profiles_write_btn';
  static const String seasonProfileDeleteBtn =
      'calendar_season_profile_delete_btn';

  // ── Special days form
  static const String spYearDropdown = 'calendar_sp_year_dropdown';
  static const String spMonthDropdown = 'calendar_sp_month_dropdown';
  static const String spDayDropdown = 'calendar_sp_day_dropdown';
  static const String spWeekdayDropdown = 'calendar_sp_weekday_dropdown';
  static const String spProfileDropdown = 'calendar_sp_profile_dropdown';
  static const String specialDayAddBtn = 'calendar_special_day_add_btn';
  static const String specialDayRemoveBtn = 'calendar_special_day_remove_btn';
  static const String specialDaysWriteBtn = 'calendar_special_days_write_btn';
}

// ── Configuration page ────────────────────────────────────────────────────
abstract class ConfigurationKeys {
  // ── Header
  static const String searchField = 'configuration_search_field';
  static const String searchClearBtn = 'configuration_search_clear_btn';
  static const String backBtn = 'configuration_back_btn';
  static const String moduleDropdown = 'configuration_module_dropdown';
  static const String saveBtn = 'configuration_save_btn';
  static const String toFileSwitch = 'configuration_to_file_switch';

  // ── General tab — communication mode row
  static const String serialActiveChk = 'configuration_serial_active_chk';
  static const String protocolDropdown = 'configuration_protocol_dropdown';
  static const String comPortDropdown = 'configuration_com_port_dropdown';
  static const String comPortRefreshBtn = 'configuration_com_port_refresh_btn';
  static const String baudRateDropdown = 'configuration_baud_rate_dropdown';

  // ── General tab — GPRS
  static const String gprsActiveChk = 'configuration_gprs_active_chk';
  static const String gprsIpField = 'configuration_gprs_ip_field';
  static const String gprsPortField = 'configuration_gprs_port_field';

  // ── General tab — PLC IPv4
  static const String plcIpv4ActiveChk = 'configuration_plc_ipv4_active_chk';
  static const String plcIpv4IpField = 'configuration_plc_ipv4_ip_field';
  static const String plcIpv4PortField = 'configuration_plc_ipv4_port_field';

  // ── General tab — PLC IPv6
  static const String plcIpv6ActiveChk = 'configuration_plc_ipv6_active_chk';
  static const String plcIpv6IpField = 'configuration_plc_ipv6_ip_field';
  static const String plcIpv6PortField = 'configuration_plc_ipv6_port_field';

  // ── General tab — addressing
  static const String clientAddrField = 'configuration_client_addr_field';
  static const String clientAddrLenField =
      'configuration_client_addr_len_field';
  static const String serverAddrField = 'configuration_server_addr_field';
  static const String serverAddrLenField =
      'configuration_server_addr_len_field';
  static const String callingAeInvocationIdField =
      'configuration_calling_ae_invocation_id_field';
  static const String systemTitleField = 'configuration_system_title_field';
  static const String preEstablishedChk = 'configuration_pre_established_chk';

  // ── General tab — HDLC timeout
  static const String hdlcTimeoutField = 'configuration_hdlc_timeout_field';
  static const String hdlcTimeoutApplyBtn =
      'configuration_hdlc_timeout_apply_btn';

  // ── Communication tab — Phy
  static const String modeComDropdown = 'configuration_mode_com_dropdown';

  // ── Communication tab — HDLC negotiation
  static const String hdlcNegChk = 'configuration_hdlc_neg_chk';
  static const String maxInfoTxLenField = 'configuration_max_info_tx_len_field';
  static const String maxInfoTxValField = 'configuration_max_info_tx_val_field';
  static const String maxInfoRxLenField = 'configuration_max_info_rx_len_field';
  static const String maxInfoRxValField = 'configuration_max_info_rx_val_field';
  static const String winSizeTxLenField = 'configuration_win_size_tx_len_field';
  static const String winSizeTxValField = 'configuration_win_size_tx_val_field';
  static const String winSizeRxLenField = 'configuration_win_size_rx_len_field';
  static const String winSizeRxValField = 'configuration_win_size_rx_val_field';

  // ── Communication tab — App Setting
  static const String ctosSizeField = 'configuration_ctos_size_field';
  static const String passwordField = 'configuration_password_field';

  // ── Communication tab — PDU / Keep Connection / HLS Action
  static const String maxPduSizeField = 'configuration_max_pdu_size_field';
  static const String keepConnectionChk = 'configuration_keep_connection_chk';
  static const String keepConnectionTimeoutField =
      'configuration_keep_connection_timeout_field';
  static const String hlsActionObisField =
      'configuration_hls_action_obis_field';
  static const String hlsActionClassField =
      'configuration_hls_action_class_field';
  static const String hlsActionMethodField =
      'configuration_hls_action_method_field';

  // ── Conformance tab
  static const String conformanceSelectAllChk =
      'configuration_conformance_select_all_chk';
  // Dynamic per-bit keys: 'configuration_conformance_bit_${i}_inkwell'
  //                       'configuration_conformance_bit_${i}_chk'

  // ── Security tab
  static const String securitySuiteDropdown =
      'configuration_security_suite_dropdown';
  static const String securityLevelDropdown =
      'configuration_security_level_dropdown';
  static const String securityPolicyDropdown =
      'configuration_security_policy_dropdown';
  static const String generalSigningChk = 'configuration_general_signing_chk';
  static const String viewerPrivateSigningKeyField =
      'configuration_viewer_private_signing_key_field';
  static const String meterPublicSigningKeyField =
      'configuration_meter_public_signing_key_field';
  static const String hlsSecretKeyField = 'configuration_hls_secret_key_field';
  static const String masterKeyField = 'configuration_master_key_field';
  static const String globalKeyField = 'configuration_global_key_field';
  static const String authKeyField = 'configuration_auth_key_field';
  static const String useDedicatedKeyChk =
      'configuration_use_dedicated_key_chk';
  static const String dedicatedKeyField = 'configuration_dedicated_key_field';
  static const String getFrameCounterChk =
      'configuration_get_frame_counter_chk';
  static const String proposedFrameCounterField =
      'configuration_proposed_frame_counter_field';
  static const String publicClientAddrField =
      'configuration_public_client_addr_field';
  static const String frameCounterObisField =
      'configuration_frame_counter_obis_field';
  static const String frameCounterClassField =
      'configuration_frame_counter_class_field';
  static const String frameCounterAttrField =
      'configuration_frame_counter_attr_field';

  // ── Diagnostics tab
  static const String diagPingBtn = 'configuration_diag_ping_btn';
  static const String diagTraceBtn = 'configuration_diag_trace_btn';
  static const String diagProfilDropdown = 'configuration_diag_profil_dropdown';
  static const String diagExportLogBtn = 'configuration_diag_export_log_btn';
  static const String diagTestConnBtn = 'configuration_diag_test_conn_btn';
  static const String diagSyncClockBtn = 'configuration_diag_sync_clock_btn';
  static const String diagNegotiateBtn = 'configuration_diag_negotiate_btn';
  static const String diagOpenSessionBtn =
      'configuration_diag_open_session_btn';
  static const String diagCloseSessionBtn =
      'configuration_diag_close_session_btn';
  static const String diagStartAssocBtn = 'configuration_diag_start_assoc_btn';
  static const String diagReleaseAssocBtn =
      'configuration_diag_release_assoc_btn';
  static const String diagStartLatencyBtn =
      'configuration_diag_start_latency_btn';
  static const String diagSeedLatenciesBtn =
      'configuration_diag_seed_latencies_btn';
  static const String diagSpamLogBtn = 'configuration_diag_spam_log_btn';
  static const String diagPasswordField = 'configuration_diag_password_field';
}

// ── Date Time page ────────────────────────────────────────────────────────
abstract class DateTimeKeys {
  // ── Clock Setting tab — Date/Time card
  static const String clockCardToggle = 'datetime_datetime_card_toggle';
  static const String clockDayDropdown = 'datetime_clock_day_dropdown';
  static const String clockMonthDropdown = 'datetime_clock_month_dropdown';
  static const String clockYearDropdown = 'datetime_clock_year_dropdown';
  static const String clockTimePicker = 'datetime_clock_time_picker';
  static const String clockReadBtn = 'datetime_clock_read_btn';
  static const String clockWriteBtn = 'datetime_clock_write_btn';
  static const String clockUpdateBtn = 'datetime_clock_update_btn';

  // ── Clock Setting tab — Time Zone card
  static const String timezoneCardToggle = 'datetime_timezone_card_toggle';
  static const String timezoneOffsetField = 'datetime_timezone_offset_field';
  static const String timezoneReadBtn = 'datetime_timezone_read_btn';
  static const String timezoneWriteBtn = 'datetime_timezone_write_btn';

  // ── Daylight Savings tab — Incremental Date card
  static const String incDateCardToggle = 'datetime_inc_date_card_toggle';
  static const String incDayDropdown = 'datetime_inc_day_dropdown';
  static const String incMonthDropdown = 'datetime_inc_month_dropdown';
  static const String incDayOfWeekDropdown =
      'datetime_inc_day_of_week_dropdown';
  static const String incTimePicker = 'datetime_inc_time_picker';
  static const String incDateReadBtn = 'datetime_inc_date_read_btn';
  static const String incDateWriteBtn = 'datetime_inc_date_write_btn';

  // ── Daylight Savings tab — Decremental Date card
  static const String decDateCardToggle = 'datetime_dec_date_card_toggle';
  static const String decDayDropdown = 'datetime_dec_day_dropdown';
  static const String decMonthDropdown = 'datetime_dec_month_dropdown';
  static const String decDayOfWeekDropdown =
      'datetime_dec_day_of_week_dropdown';
  static const String decTimePicker = 'datetime_dec_time_picker';
  static const String decDateReadBtn = 'datetime_dec_date_read_btn';
  static const String decDateWriteBtn = 'datetime_dec_date_write_btn';

  // ── Daylight Savings tab — DST Deviation card
  static const String dstDeviationCardToggle =
      'datetime_dst_deviation_card_toggle';
  static const String dstDeviationField = 'datetime_dst_deviation_field';
  static const String dstDeviationReadBtn = 'datetime_dst_deviation_read_btn';
  static const String dstDeviationWriteBtn = 'datetime_dst_deviation_write_btn';

  // ── Daylight Savings tab — DST Activation card
  static const String dstActivationCardToggle =
      'datetime_dst_activation_card_toggle';
  static const String dstActiveSwitch = 'datetime_dst_active_switch';
  static const String dstActivationReadBtn = 'datetime_dst_activation_read_btn';
  static const String dstActivationWriteBtn =
      'datetime_dst_activation_write_btn';
}

// ── Device ID page ────────────────────────────────────────────────────────
abstract class DeviceIdKeys {
  // ── App bar
  static const String exportBtn = 'device_id_export_btn';

  // ── Error banner
  static const String dismissErrorBtn = 'device_id_dismiss_error_btn';

  // ── Form action buttons
  static const String resetBtn = 'device_id_reset_btn';
  static const String readBtn = 'device_id_read_btn';
  static const String writeBtn = 'device_id_write_btn';

  // ── Write-confirm dialog
  static const String writeConfirmCancelBtn =
      'device_id_write_confirm_cancel_btn';
  static const String writeConfirmApplyBtn =
      'device_id_write_confirm_apply_btn';

  // ── Dynamic field keys — pattern: 'device_id_{label_snake_case}_field'
  static String fieldKey(String label) =>
      'device_id_${label.toLowerCase().replaceAll(' ', '_')}_field';
}

// ── DLMS Translator page ──────────────────────────────────────────────────
abstract class DlmsTranslatorKeys {
  static const String inputField = 'dlms_translator_input_field';
  static const String outputField = 'dlms_translator_output_field';
  static const String translateBtn = 'dlms_translator_translate_btn';
  static const String clearBtn = 'dlms_translator_clear_btn';
  static const String copyOutputBtn = 'dlms_translator_copy_output_btn';
  static const String dismissErrorBtn = 'dlms_translator_dismiss_error_btn';
}

// ── Energy Register page ──────────────────────────────────────────────────
abstract class EnergyRegisterKeys {
  // ── App bar
  static const String exportBtn = 'energy_register_export_btn';

  // ── Error banner
  static const String dismissErrorBtn = 'energy_register_dismiss_error_btn';

  // ── Detail panel
  static const String registerDropdown = 'energy_register_dropdown';
}

// ── Event Logs page ───────────────────────────────────────────────────────
abstract class EventLogsKeys {
  // ── App bar
  static const String exportBtn = 'event_logs_export_btn';

  // ── Loading overlay
  static const String abortBtn = 'event_logs_abort_btn';

  // ── Events tab — action buttons
  static const String partialReadBtn = 'event_logs_partial_read_btn';
  static const String fullReadBtn = 'event_logs_full_read_btn';

  // ── Events tab — pagination bar
  static const String firstPageBtn = 'event_logs_first_page_btn';
  static const String prevPageBtn = 'event_logs_prev_page_btn';
  static const String nextPageBtn = 'event_logs_next_page_btn';
  static const String lastPageBtn = 'event_logs_last_page_btn';
  static const String pageSizeDropdown = 'event_logs_page_size_dropdown';

  // ── Events tab — stat filter cards (dynamic)
  // Pattern: 'event_logs_stat_card_{value}'
  static String statCardKey(int value) => 'event_logs_stat_card_$value';

  // ── Console tab (currently hidden)
  static const String consoleClearBtn = 'event_logs_console_clear_btn';
  static const String consoleExportBtn = 'event_logs_console_export_btn';

  // ── Export tab (currently hidden)
  static const String secureExportBtn = 'event_logs_secure_export_btn';
  static const String zipExportBtn = 'event_logs_zip_export_btn';
}

// ── Firmware Download page ────────────────────────────────────────────────
abstract class FirmwareDownloadKeys {
  // ── Tab bar
  static const String settingsTabBtn = 'firmware_settings_tab_btn';
  static const String downloadTabBtn = 'firmware_download_tab_btn';
  static const String blocksTabBtn = 'firmware_blocks_tab_btn';

  // ── Settings tab — Authorization Transfer
  static const String authReadBtn = 'firmware_auth_read_btn';
  static const String authWriteBtn = 'firmware_auth_write_btn';

  // ── Settings tab — Block Size
  static const String blockSizeField = 'firmware_block_size_field';
  static const String blockSizeReadBtn = 'firmware_block_size_read_btn';
  static const String blockSizeWriteBtn = 'firmware_block_size_write_btn';

  // ── Settings tab — Transfer State
  static const String refreshStatusBtn = 'firmware_refresh_status_btn';

  // ── Settings tab — Activation Date/Time dropdowns
  static const String activationYearDropdown =
      'firmware_activation_year_dropdown';
  static const String activationMonthDropdown =
      'firmware_activation_month_dropdown';
  static const String activationDayDropdown =
      'firmware_activation_day_dropdown';
  static const String activationHourDropdown =
      'firmware_activation_hour_dropdown';
  static const String activationMinuteDropdown =
      'firmware_activation_minute_dropdown';
  static const String activationSecondDropdown =
      'firmware_activation_second_dropdown';

  // ── Settings tab — Activation actions
  static const String activationDatetimeReadBtn =
      'firmware_activation_datetime_read_btn';
  static const String activationDatetimeWriteBtn =
      'firmware_activation_datetime_write_btn';
  static const String activateBtn = 'firmware_activate_btn';

  // ── Download tab — Firmware Process
  static const String fileUploadArea = 'firmware_file_upload_area';
  static const String imageIdField = 'firmware_image_id_field';
  static const String channelDropdown = 'firmware_channel_dropdown';
  static const String prepareInitTransferBtn =
      'firmware_prepare_init_transfer_btn';

  // ── Download tab — Download Process
  static const String downloadBtn = 'firmware_download_btn';
  static const String resumeBtn = 'firmware_resume_btn';
  static const String cancelBtn = 'firmware_cancel_btn';

  // ── Blocks tab
  static const String blocksRefreshBtn = 'firmware_blocks_refresh_btn';
  static const String blocksActivateBtn = 'firmware_blocks_activate_btn';
  static const String blocksResendBtn = 'firmware_blocks_resend_btn';
}

// ── Firmware Version page ─────────────────────────────────────────────────
abstract class FirmwareVersionKeys {
  // ── App bar
  static const String exportBtn = 'firmware_version_export_btn';
  static const String refreshBtn = 'firmware_version_refresh_btn';

  // ── Error banner
  static const String dismissErrorBtn = 'firmware_version_dismiss_error_btn';

  // ── Action buttons
  static const String resetBtn = 'firmware_version_reset_btn';
  static const String readBtn = 'firmware_version_read_btn';
  static const String writeBtn = 'firmware_version_write_btn';

  // ── Write-confirm dialog
  static const String writeConfirmCancelBtn =
      'firmware_version_write_confirm_cancel_btn';
  static const String writeConfirmApplyBtn =
      'firmware_version_write_confirm_apply_btn';

  // ── Dynamic field keys — pattern: 'firmware_version_{label_snake_case}_field'
  static String fieldKey(String label) =>
      'firmware_version_${label.toLowerCase().replaceAll(' ', '_')}_field';
}

// ── Fresnel Diagram page ──────────────────────────────────────────────────
abstract class FresnelDiagramKeys {
  // ── App bar
  static const String exportBtn = 'fresnel_export_btn';
  static const String refreshBtn = 'fresnel_refresh_btn';

  // ── Configuration card
  static const String pollIntervalField = 'fresnel_poll_interval_field';
  static const String startBtn = 'fresnel_start_btn';
  static const String stopBtn = 'fresnel_stop_btn';
}

// ── Load Profile page ─────────────────────────────────────────────────────
abstract class LoadProfileKeys {
  // ── App bar
  static const String exportBtn = 'load_profile_export_btn';
  static const String refreshBtn = 'load_profile_refresh_btn';

  // ── Tab bar
  static const String tableTabBtn = 'load_profile_table_tab_btn';
  static const String chartTabBtn = 'load_profile_chart_tab_btn';

  // ── Loading overlay
  static const String abortBtn = 'load_profile_abort_btn';

  // ── Table tab — action buttons
  static const String fullReadBtn = 'load_profile_full_read_btn';

  // ── Table tab — pagination bar
  static const String firstPageBtn = 'load_profile_first_page_btn';
  static const String prevPageBtn = 'load_profile_prev_page_btn';
  static const String nextPageBtn = 'load_profile_next_page_btn';
  static const String lastPageBtn = 'load_profile_last_page_btn';
  static const String pageSizeDropdown = 'load_profile_page_size_dropdown';
}

// ── Load Profile Status page ──────────────────────────────────────────────
abstract class LoadProfileStatusKeys {
  // ── App bar
  static const String exportBtn = 'load_profile_status_export_btn';
  static const String refreshBtn = 'load_profile_status_refresh_btn';

  // ── Error state
  static const String retryBtn = 'load_profile_status_retry_btn';
}

// ── Meter Connexion page ──────────────────────────────────────────────────
abstract class MeterConnexionKeys {
  // ── App bar
  static const String refreshBtn = 'meter_connexion_refresh_btn';

  // ── Connection Setup card
  static const String datamodelDropdown = 'meter_connexion_datamodel_dropdown';
  static const String moduleDropdown = 'meter_connexion_module_dropdown';

  // ── Authentication card
  static const String passwordField = 'meter_connexion_password_field';
  static const String hexFormatChk = 'meter_connexion_hex_format_chk';

  // ── Simulation card
  static const String simulationSwitch = 'meter_connexion_simulation_switch';
  static const String simulationBrowseBtn =
      'meter_connexion_simulation_browse_btn';

  // ── Actions panel
  static const String connectBtn = 'meter_connexion_connect_btn';
  static const String disconnectBtn = 'meter_connexion_disconnect_btn';
  static const String configurationBtn = 'meter_connexion_configuration_btn';
}

// ── Mobile Network ID page ────────────────────────────────────────────────
abstract class MobileNetworkIdKeys {
  // ── App bar
  static const String refreshBtn = 'mobile_network_refresh_btn';

  // ── Error banner
  static const String dismissErrorBtn = 'mobile_network_dismiss_error_btn';

  // ── Identifiers section — IMSI
  static const String imsiField = 'mobile_network_imsi_field';
  static const String imsiReadBtn = 'mobile_network_imsi_read_btn';
  static const String imsiWriteBtn = 'mobile_network_imsi_write_btn';

  // ── Identifiers section — MSISDN
  static const String msisdnField = 'mobile_network_msisdn_field';
  static const String msisdnReadBtn = 'mobile_network_msisdn_read_btn';
  static const String msisdnWriteBtn = 'mobile_network_msisdn_write_btn';

  // ── Identifiers section — IMEI
  static const String imeiField = 'mobile_network_imei_field';
  static const String imeiReadBtn = 'mobile_network_imei_read_btn';
  static const String imeiWriteBtn = 'mobile_network_imei_write_btn';

  // ── Identifiers section — ICCID
  static const String iccidField = 'mobile_network_iccid_field';
  static const String iccidReadBtn = 'mobile_network_iccid_read_btn';
  static const String iccidWriteBtn = 'mobile_network_iccid_write_btn';

  // ── Modem Control section
  static const String modemActivateBtn = 'mobile_network_modem_activate_btn';
  static const String modemDeactivateBtn =
      'mobile_network_modem_deactivate_btn';
  static const String modemRestartBtn = 'mobile_network_modem_restart_btn';
  static const String modemRefreshBtn = 'mobile_network_modem_refresh_btn';

  // ── Restart confirm dialog
  static const String modemRestartCancelBtn =
      'mobile_network_modem_restart_cancel_btn';
  static const String modemRestartConfirmBtn =
      'mobile_network_modem_restart_confirm_btn';
}

// ── Modem Config page ─────────────────────────────────────────────────────
abstract class ModemConfigKeys {
  // ── App bar
  static const String refreshBtn = 'modem_config_refresh_btn';

  // ── Error banner
  static const String dismissErrorBtn = 'modem_config_dismiss_error_btn';

  // ── Tab bar
  static const String modemConfigTab = 'modem_config_tab_modem_config';
  static const String autoConnectTab = 'modem_config_tab_auto_connect';
  static const String autoAnswerTab = 'modem_config_tab_auto_answer';
  static const String tcpUdpTab = 'modem_config_tab_tcp_udp';

  // ── Tab 1 — Modem Configuration
  static const String commSpeedDropdown = 'modem_comm_speed_dropdown';
  static const String commSpeedReadBtn = 'modem_comm_speed_read_btn';
  static const String commSpeedWriteBtn = 'modem_comm_speed_write_btn';
  static const String profileField = 'modem_profile_field';
  static const String profileReadBtn = 'modem_profile_read_btn';
  static const String profileWriteBtn = 'modem_profile_write_btn';
  static const String initAddRowBtn = 'modem_init_add_row_btn';
  static const String initStringsReadBtn = 'modem_init_strings_read_btn';
  static const String initStringsWriteBtn = 'modem_init_strings_write_btn';
  // Dynamic init string row keys
  static String initRequestField(int i) => 'modem_init_request_${i}_field';
  static String initExpectedField(int i) => 'modem_init_expected_${i}_field';
  static String initDelayField(int i) => 'modem_init_delay_${i}_field';

  // ── Tab 2 — Auto Connect
  static const String autoConnectModeDropdown =
      'modem_auto_connect_mode_dropdown';
  static const String autoConnectModeReadBtn =
      'modem_auto_connect_mode_read_btn';
  static const String autoConnectModeWriteBtn =
      'modem_auto_connect_mode_write_btn';
  static const String repetitionsField = 'modem_repetitions_field';
  static const String repetitionsReadBtn = 'modem_repetitions_read_btn';
  static const String repetitionsWriteBtn = 'modem_repetitions_write_btn';
  static const String repetitionDelayField = 'modem_repetition_delay_field';
  static const String repetitionDelayReadBtn =
      'modem_repetition_delay_read_btn';
  static const String repetitionDelayWriteBtn =
      'modem_repetition_delay_write_btn';
  static const String destinationReadBtn = 'modem_destination_read_btn';
  static const String callingWindowAddBtn = 'modem_calling_window_add_btn';
  static const String callingWindowReadBtn = 'modem_calling_window_read_btn';
  static const String callingWindowWriteBtn = 'modem_calling_window_write_btn';
  static const String connectBtn = 'modem_connect_btn';

  // ── Tab 3 — Auto Answer
  static const String autoAnswerModeDropdown =
      'modem_auto_answer_mode_dropdown';
  static const String autoAnswerModeReadBtn = 'modem_auto_answer_mode_read_btn';
  static const String autoAnswerModeWriteBtn =
      'modem_auto_answer_mode_write_btn';
  static const String nbCallsField = 'modem_nb_calls_field';
  static const String nbCallsReadBtn = 'modem_nb_calls_read_btn';
  static const String nbCallsWriteBtn = 'modem_nb_calls_write_btn';
  static const String ringsInField = 'modem_rings_in_field';
  static const String ringsInReadBtn = 'modem_rings_in_read_btn';
  static const String ringsInWriteBtn = 'modem_rings_in_write_btn';
  static const String ringsOutField = 'modem_rings_out_field';
  static const String ringsOutReadBtn = 'modem_rings_out_read_btn';
  static const String ringsOutWriteBtn = 'modem_rings_out_write_btn';
  static const String autoAnswerStatusDropdown =
      'modem_auto_answer_status_dropdown';
  static const String autoAnswerStatusReadBtn =
      'modem_auto_answer_status_read_btn';
  static const String allowedCallersAddBtn = 'modem_allowed_callers_add_btn';
  static const String allowedCallersReadBtn = 'modem_allowed_callers_read_btn';
  static const String allowedCallersWriteBtn =
      'modem_allowed_callers_write_btn';
  static const String listeningWindowAddBtn = 'modem_listening_window_add_btn';
  static const String listeningWindowReadBtn =
      'modem_listening_window_read_btn';
  static const String listeningWindowWriteBtn =
      'modem_listening_window_write_btn';

  // ── Tab 4 — TCP/UDP Setup
  static const String tcpPortField = 'modem_tcp_port_field';
  static const String tcpPortReadBtn = 'modem_tcp_port_read_btn';
  static const String tcpPortWriteBtn = 'modem_tcp_port_write_btn';
  static const String ipReferenceField = 'modem_ip_reference_field';
  static const String ipReferenceReadBtn = 'modem_ip_reference_read_btn';
  static const String mssField = 'modem_mss_field';
  static const String mssReadBtn = 'modem_mss_read_btn';
  static const String mssWriteBtn = 'modem_mss_write_btn';
  static const String nbConnectionsField = 'modem_nb_connections_field';
  static const String nbConnectionsReadBtn = 'modem_nb_connections_read_btn';
  static const String nbConnectionsWriteBtn = 'modem_nb_connections_write_btn';
  static const String inactivityTimeoutField = 'modem_inactivity_timeout_field';
  static const String inactivityTimeoutReadBtn =
      'modem_inactivity_timeout_read_btn';
  static const String inactivityTimeoutWriteBtn =
      'modem_inactivity_timeout_write_btn';
}

// ── Script Table page ─────────────────────────────────────────────────────
abstract class ScriptTableKeys {
  static const String readBtn = 'script_table_read_btn';
  static const String executeBtn = 'script_table_execute_btn';
}

// ── Push Setup Server page ────────────────────────────────────────────────
abstract class PushSetupServerKeys {
  // ── App bar
  static const String clearNotificationsBtn =
      'push_server_clear_notifications_btn';

  // ── Configuration card
  static const String hostField = 'push_server_host_field';
  static const String portField = 'push_server_port_field';
  static const String typeDropdown = 'push_server_type_dropdown';
  static const String startBtn = 'push_server_start_btn';
  static const String stopBtn = 'push_server_stop_btn';

  // ── Notification cards (dynamic, indexed by position i)
  // Pattern: 'push_server_notification_{i}_toggle'
  static String notificationToggle(int i) =>
      'push_server_notification_${i}_toggle';
  // Pattern: 'push_server_notification_{i}_copy_btn'
  static String notificationCopyBtn(int i) =>
      'push_server_notification_${i}_copy_btn';
}

// ── Push Setup page ───────────────────────────────────────────────────────
abstract class PushSetupKeys {
  // ── Tab bar (dynamic, one tab per config entry)
  static String tab(int i) => 'push_setup_tab_$i';

  // ── Object list panel
  static const String filterField = 'push_setup_filter_field';

  // ── Attributes panel
  static const String selectAllBtn = 'push_setup_select_all_btn';
  static const String clearAllBtn = 'push_setup_clear_all_btn';

  // ── Capture list panel header
  static const String captureLoadBtn = 'push_setup_capture_load_btn';
  static const String captureWriteBtn = 'push_setup_capture_write_btn';
  static const String captureClearBtn = 'push_setup_capture_clear_btn';

  // ── Push parameters — Randomisation start interval
  static const String randomStartField = 'push_setup_random_start_field';
  static const String randomStartReadBtn = 'push_setup_random_start_read_btn';
  static const String randomStartWriteBtn = 'push_setup_random_start_write_btn';

  // ── Push parameters — Number of retries
  static const String retriesField = 'push_setup_retries_field';
  static const String retriesReadBtn = 'push_setup_retries_read_btn';
  static const String retriesWriteBtn = 'push_setup_retries_write_btn';

  // ── Push parameters — Repetition delay
  static const String repDelayMinField = 'push_setup_rep_delay_min_field';
  static const String repDelayExpField = 'push_setup_rep_delay_exp_field';
  static const String repDelayMaxField = 'push_setup_rep_delay_max_field';
  static const String repDelayReadBtn = 'push_setup_rep_delay_read_btn';
  static const String repDelayWriteBtn = 'push_setup_rep_delay_write_btn';

  // ── Push parameters — Last confirmation datetime
  static const String lastConfirmDtBtn = 'push_setup_last_confirm_dt_btn';
  static const String lastConfirmReadBtn = 'push_setup_last_confirm_read_btn';
  static const String lastConfirmWriteBtn = 'push_setup_last_confirm_write_btn';

  // ── Push / Reset action buttons
  static const String pushBtn = 'push_setup_push_btn';
  static const String resetBtn = 'push_setup_reset_btn';

  // ── Reset confirm dialog
  static const String resetConfirmCancelBtn =
      'push_setup_reset_confirm_cancel_btn';
  static const String resetConfirmBtn = 'push_setup_reset_confirm_btn';

  // ── Send destination section
  static const String transportServiceDropdown =
      'push_setup_transport_service_dropdown';
  static const String destinationField = 'push_setup_destination_field';
  static const String messageTypeDropdown = 'push_setup_message_type_dropdown';
  static const String sendDestReadBtn = 'push_setup_send_dest_read_btn';
  static const String sendDestWriteBtn = 'push_setup_send_dest_write_btn';

  // ── Communication window section
  static const String commWindowReadBtn = 'push_setup_comm_window_read_btn';
  static const String commWindowWriteBtn = 'push_setup_comm_window_write_btn';
  static const String commWindowAddBtn = 'push_setup_comm_window_add_btn';
  // Dynamic: row delete button — 'push_setup_comm_window_delete_{i}_btn'
  static String commWindowDeleteBtn(int i) =>
      'push_setup_comm_window_delete_${i}_btn';

  // ── Add communication window dialog
  static const String commWindowDialogCancelBtn =
      'push_setup_comm_window_dialog_cancel_btn';
  static const String commWindowDialogAddBtn =
      'push_setup_comm_window_dialog_add_btn';
}

// ── Push Selective page ───────────────────────────────────────────────────
abstract class PushSelectiveKeys {
  // ── Tab bar (dynamic, one tab per object)
  // Pattern: 'push_selective_tab_{i}'
  static String tab(int i) => 'push_selective_tab_$i';

  // ── Capture Objects panel (per-tab, indexed by object index i)
  static String searchField(int i) => 'push_selective_search_${i}_field';
  static String searchClearBtn(int i) => 'push_selective_search_${i}_clear_btn';
  static String captureRetryBtn(int i) =>
      'push_selective_capture_${i}_retry_btn';

  // ── Filter Buffer panel — row delete button (per-tab, per-row)
  // Pattern: 'push_selective_remove_{tabIndex}_{rowIndex}_btn'
  static String removeBtn(int tabIndex, int rowIndex) =>
      'push_selective_remove_${tabIndex}_${rowIndex}_btn';
}

// ── Push Recovery page ────────────────────────────────────────────────────
abstract class PushRecoveryKeys {
  // ── Card header — error state
  static const String refreshBtn = 'push_recovery_refresh_btn';
}

// ── Push Action page ──────────────────────────────────────────────────────
abstract class PushActionKeys {
  // ── Execution time section
  static const String execTimeReadBtn = 'push_action_exec_time_read_btn';
  static const String execTimeWriteBtn = 'push_action_exec_time_write_btn';
  static const String addExecTimeBtn = 'push_action_add_exec_time_btn';
  // Dynamic: exec time row delete buttons
  static String execTimeDeleteBtn(int i) =>
      'push_action_exec_time_delete_${i}_btn';

  // ── Schedule type section
  static const String scheduleTypeReadBtn =
      'push_action_schedule_type_read_btn';

  // ── Executed script section
  static const String executedScriptReadBtn =
      'push_action_executed_script_read_btn';
  static const String executedScriptWriteBtn =
      'push_action_executed_script_write_btn';
  static const String scriptTableField = 'push_action_script_table_field';
  static const String scriptSelectorField = 'push_action_script_selector_field';
  static const String scriptTextField = 'push_action_script_text_field';

  // ── Add execution time dialog
  static const String execTimeDayDropdown =
      'push_action_exec_time_day_dropdown';
  static const String execTimeMonthDropdown =
      'push_action_exec_time_month_dropdown';
  static const String execTimeYearDropdown =
      'push_action_exec_time_year_dropdown';
  static const String execTimeWeekdayDropdown =
      'push_action_exec_time_weekday_dropdown';
  static const String execTimeHourDropdown =
      'push_action_exec_time_hour_dropdown';
  static const String execTimeMinuteDropdown =
      'push_action_exec_time_minute_dropdown';
  static const String execTimeSecondDropdown =
      'push_action_exec_time_second_dropdown';
  static const String execTimeMsDropdown = 'push_action_exec_time_ms_dropdown';
  static const String execTimeCancelBtn = 'push_action_exec_time_cancel_btn';
  static const String execTimeAddBtn = 'push_action_exec_time_add_btn';
}

// ── SIM Config page ───────────────────────────────────────────────────────
abstract class SimConfigKeys {
  // ── Error banner
  static const String dismissErrorBtn = 'sim_config_dismiss_error_btn';

  // ── Modem Config section — fields
  static const String apnField = 'sim_apn_field';
  static const String pinField = 'sim_pin_field';
  static const String pppUserField = 'sim_ppp_user_field';
  static const String pppPassField = 'sim_ppp_pass_field';

  // ── Modem Config section — action buttons
  static const String apnReadBtn = 'sim_apn_read_btn';
  static const String apnWriteBtn = 'sim_apn_write_btn';
  static const String pinReadBtn = 'sim_pin_read_btn';
  static const String pinWriteBtn = 'sim_pin_write_btn';
  static const String pppReadBtn = 'sim_ppp_read_btn';
  static const String pppWriteBtn = 'sim_ppp_write_btn';

  // ── IP Address section
  static const String ipField = 'sim_ip_field';
  static const String ipReadBtn = 'sim_ip_read_btn';
  static const String ipWriteBtn = 'sim_ip_write_btn';

  // ── Cellular Diag section — fields / dropdowns
  static const String operatorField = 'sim_operator_field';
  static const String statusDropdown = 'sim_status_dropdown';
  static const String csAttachmentDropdown = 'sim_cs_attachment_dropdown';
  static const String psStatusDropdown = 'sim_ps_status_dropdown';

  // ── Cellular Diag section — action buttons
  static const String operatorReadBtn = 'sim_operator_read_btn';
  static const String statusReadBtn = 'sim_status_read_btn';
  static const String csAttachmentReadBtn = 'sim_cs_attachment_read_btn';
  static const String psStatusReadBtn = 'sim_ps_status_read_btn';

  // ── Cell Info section
  static const String cellInfoValueField = 'sim_cell_info_value_field';
  static const String cellInfoReadBtn = 'sim_cell_info_read_btn';
  static const String cellInfoWriteBtn = 'sim_cell_info_write_btn';

  // ── QoS section — edit fields
  static const String qosPrecedenceField = 'sim_qos_precedence_field';
  static const String qosDelayField = 'sim_qos_delay_field';
  static const String qosReliabilityField = 'sim_qos_reliability_field';
  static const String qosPeakField = 'sim_qos_peak_field';
  static const String qosMeanField = 'sim_qos_mean_field';

  // ── QoS section — action buttons
  static const String qosReadBtn = 'sim_qos_read_btn';
  static const String qosWriteBtn = 'sim_qos_write_btn';
}

// ── Super Manual Tool page ────────────────────────────────────────────────
abstract class SuperManualToolKeys {
  // ── Tab bar (dynamic by tab key: 'send' | 'selective')
  static String tabBtn(String key) => 'super_manual_tab_${key}_btn';

  // ── Send tab — Dictionaries panel
  static const String dictFilterField = 'super_manual_dict_filter_field';

  // ── Send tab — Attributes panel (dynamic per attribute id)
  static String attrCheckbox(int id) => 'super_manual_attr_${id}_chk';
  static String attrSetValueBtn(int id) =>
      'super_manual_attr_${id}_set_value_btn';

  // ── Send tab — Description panel
  static const String decimalFormatChk = 'super_manual_decimal_format_chk';

  // ── Send tab — action buttons
  static const String getBtn = 'super_manual_get_btn';
  static const String setBtn = 'super_manual_set_btn';
  static const String actionBtn = 'super_manual_action_btn';

  // ── Send tab — Results panel
  static const String encodeBtn = 'super_manual_encode_btn';
  static const String decodeBtn = 'super_manual_decode_btn';
  static const String clearEncodingBtn = 'super_manual_clear_encoding_btn';

  // ── Selective tab — Dictionaries panel
  static const String selFilterField = 'super_manual_sel_filter_field';
  // Dynamic: list item selection button
  static String selItemBtn(String logicalName) =>
      'super_manual_sel_item_${logicalName}_btn';

  // ── Selective tab — Capture Information panel
  static const String recordMaxField = 'super_manual_record_max_field';
  static const String recordNumField = 'super_manual_record_num_field';
  static const String capturePeriodField = 'super_manual_capture_period_field';
  static const String captureTypeDropdown =
      'super_manual_capture_type_dropdown';
  static const String selReadBtn = 'super_manual_sel_read_btn';

  // ── Selective tab — Selective Access Operator panel
  static const String operatorTypeDropdown =
      'super_manual_operator_type_dropdown';
  static const String opExpressionField = 'super_manual_op_expression_field';

  // Range descriptor date/time pickers (dynamic by label)
  static String dateTimePicker(String label) =>
      'super_manual_datetime_${label.toLowerCase().replaceAll(' ', '_')}_picker';

  // Entry descriptor fields
  static const String entryStartField = 'super_manual_entry_start_field';
  static const String entryEndField = 'super_manual_entry_end_field';
  static const String selectedStartField = 'super_manual_selected_start_field';
  static const String selectedEndField = 'super_manual_selected_end_field';

  // Operator buttons
  static const String opConfigBtn = 'super_manual_op_config_btn';
  static const String opDecodeBtn = 'super_manual_op_decode_btn';
  static const String opEncodeBtn = 'super_manual_op_encode_btn';
  static const String opReadBtn = 'super_manual_op_read_btn';

  // ── Selective tab — Results panel
  static const String selectiveEncodeBtn = 'super_manual_selective_encode_btn';
  static const String selectiveDecodeBtn = 'super_manual_selective_decode_btn';
  static const String selectiveClearBtn = 'super_manual_selective_clear_btn';

  // ── Legacy method keys
  static const String opTypeDropdown = 'super_manual_op_type_dropdown';
}

// ── Template Config page ──────────────────────────────────────────────────
abstract class TemplateConfigKeys {
  // ── Main list — page entry cards (dynamic by page id)
  static String pageCard(String id) => 'template_config_page_${id}_card';

  // ── Assignment page — tokens reference panel
  static const String tokensExpandBtn = 'template_config_tokens_expand_btn';
  // Dynamic: copy gesture per token name
  static String tokenCopyBtn(String token) =>
      'template_config_token_${token}_copy';

  // ── Assignment page — format template dropdowns (format: xml / csv / pdf / docx)
  static String formatDropdown(String format) =>
      'template_config_${format}_dropdown';

  // ── Assignment page — save button
  static const String setTemplatesBtn = 'template_config_set_templates_btn';
}

// ── Gurux Translator page ─────────────────────────────────────────────────
abstract class GuruxTranslatorKeys {
  // ── PDU tab (Tab 0)
  static const String pduDirectionToggle =
      'gurux_translator_pdu_direction_toggle';
  static const String pduSwapBtn = 'gurux_translator_pdu_swap_btn';
  static const String pduInputField = 'gurux_translator_pdu_input_field';
  static const String pduOutputField = 'gurux_translator_pdu_output_field';
  static const String pduTranslateBtn =
      'gurux_translator_session_translate_btn';
  static const String pduClearBtn = 'gurux_translator_session_clear_btn';
  static const String pduCopyBtn = 'gurux_translator_session_copy_btn';
  static const String pduDismissErrorBtn =
      'gurux_translator_pdu_dismiss_error_btn';

  // ── Messages tab (Tab 1)
  static const String messagesDirectionToggle =
      'gurux_translator_messages_direction_toggle';
  static const String messagesInputField =
      'gurux_translator_messages_input_field';
  static const String messagesClearBtn = 'gurux_translator_capture_clear_btn';
  static const String messagesCopyAllBtn =
      'gurux_translator_session_copy_all_btn';
  static const String messagesTranslateAllBtn =
      'gurux_translator_session_translate_all_btn';
  static const String messagesDismissErrorBtn =
      'gurux_translator_messages_dismiss_error_btn';

  // ── DLMS Translate tab (Tab 2)
  static const String dlmsInputField = 'gurux_translator_dlms_input_field';
  static const String dlmsOutputField = 'gurux_translator_dlms_output_field';
  static const String dlmsTranslateBtn = 'gurux_translator_pdu_translate_btn';
  static const String dlmsClearBtn = 'gurux_translator_pdu_clear_btn';
  static const String dlmsCopyBtn = 'gurux_translator_pdu_copy_btn';
  static const String dlmsDismissErrorBtn =
      'gurux_translator_dlms_dismiss_error_btn';
}

// ── App Bottom Toolbar (shared widget) ───────────────────────────────────
abstract class AppBottomToolbarKeys {
  static const String datetimeBtn = 'bottom_toolbar_datetime_btn';
  static const String superManualBtn = 'bottom_toolbar_supermanual_btn';
  static const String manualDlmsBtn = 'bottom_toolbar_configuration_btn';
  static const String configurationBtn =
      'bottom_toolbar_configuration_settings_btn';
  static const String logsBtn = 'bottom_toolbar_logs_btn';
  static const String disconnectBtn = 'bottom_toolbar_disconnect_btn';
}

abstract class CTVTKeys {
  static const String mainStack = 'ct_vt_main_stack';
  static const String scrollView = 'ct_vt_scroll_view';
  static const String mainColumn = 'ct_vt_main_column';
  static const String ctSectionTitle = 'ct_vt_ct_section_title';
  static const String ctPrimaryField = 'ct_vt_ct_primary_field';
  static const String ctSecondaryField = 'ct_vt_ct_secondary_field';
  static const String ctRatioField = 'ct_vt_ct_ratio_field';
  static const String vtSectionTitle = 'ct_vt_vt_section_title';
  static const String vtPrimaryField = 'ct_vt_vt_primary_field';
  static const String vtRatioValueField = 'vt_ratio_value_field';
  static const String vtRatioField = 'ct_vt_vt_ratio_field';
}
