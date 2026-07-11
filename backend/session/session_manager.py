# ============================================
# session_manager.py
# ============================================

from typing import List, Optional, Dict


class SessionManager:
    """
    Centralise la session de l'utilisateur connecte.
    - user_role
    - right_list
    - exclude_list
    - disable_feature_list
    - trial_period_start / trial_period_end
    - enterprise (si fourni dans la licence)
    - dic_file_name (si applicable)
    """

    def __init__(self):
        self.user_role: str = ""
        self.right_list: List[str] = []
        self.exclude_list: List[str] = []
        self.disable_feature_list: List[str] = []
        self.trial_period_start: str = ""
        self.trial_period_end: str = ""
        self.enterprise: str = ""
        self.dic_file_name: str = ""

    # -----------------------------
    # Setters / Getters
    # -----------------------------

    def set_user_role(self, role: str):
        self.user_role = (role or "").strip()

    def get_user_role(self) -> str:
        return self.user_role

    def set_right_list(self, rights: Optional[List[str]]):
        self.right_list = rights or []

    def get_right_list(self) -> List[str]:
        return self.right_list

    def set_exclude_right_list(self, excludes: Optional[List[str]]):
        self.exclude_list = excludes or []

    def get_exclude_right_list(self) -> List[str]:
        return self.exclude_list

    def set_disable_feature_list(self, disables: Optional[List[str]]):
        self.disable_feature_list = disables or []

    def get_disable_feature_list(self) -> List[str]:
        return self.disable_feature_list

    def set_trial_period(self, start: str, end: str):
        self.trial_period_start = start or ""
        self.trial_period_end = end or ""

    def get_trial_period(self) -> Dict[str, str]:
        return {"start": self.trial_period_start, "end": self.trial_period_end}

    def set_enterprise(self, name: str):
        self.enterprise = name or ""

    def get_enterprise(self) -> str:
        return self.enterprise

    def set_dic_file_name(self, name: str):
        self.dic_file_name = name or ""

    def get_dic_file_name(self) -> str:
        return self.dic_file_name

    # -----------------------------
    # Droits
    # -----------------------------

    def has_right(self, right_to_check: Optional[str]) -> bool:
        if not right_to_check:
            return False
        rtc = right_to_check.lower()
        for r in self.right_list:
            if r and r.lower() == rtc:
                return True
        return False

    def get_effective_right(self, enum_right: str) -> str:
        """
        enum_right: "GET" | "SET" | "SETGET" | "ACTION"
        Retour: "GET" | "SET" | "SETGET" | "ACTION" | "NO"
        Regle override via exclude_list si dic_file_name present.
        """
        dic_name = (self.dic_file_name or "").lower()
        exclude_norm = [x.lower() for x in self.exclude_list]

        # Override (excludeRight)
        if dic_name and dic_name in exclude_norm:
            return enum_right.upper()

        e = enum_right.upper()

        if e == "GET":
            return "GET" if self.has_right("GET") else "NO"

        if e == "SET":
            return "SET" if self.has_right("SET") else "NO"

        if e == "SETGET":
            g = self.has_right("GET")
            s = self.has_right("SET")
            if g and s:
                return "SETGET"
            if g:
                return "GET"
            if s:
                return "SET"
            return "NO"

        if e == "ACTION":
            return "ACTION" if self.has_right("ACTION") else "NO"

        return "NO"


# Singleton global
SESSION = SessionManager()
