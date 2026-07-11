import base64


from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

BS = 16
pad = lambda s: s + (BS - len(s) % BS) * chr(BS - len(s) % BS)


def unpad(s):
    if isinstance(s, (bytes, bytearray)):
        pad_len = s[-1]
        return s[0:-pad_len]
    return s[0 : -ord(s[-1])]


class AESCipher:

    def __init__(self, key):
        self.key = key

    def encrypt(self, raw):

        raw = pad(raw)
        raw = raw.encode("Windows-1252")
        iv = "_DMTTICSAGEMCOM_".encode("Windows-1252")
        cipher = Cipher(algorithms.AES(self.key.encode("Windows-1252")), modes.CBC(iv))
        encryptor = cipher.encryptor()
        ciphered = encryptor.update(raw) + encryptor.finalize()
        return base64.b64encode(ciphered)

    def decrypt(self, enc):
        enc = base64.b64decode(enc)
        iv = "_DMTTICSAGEMCOM_".encode("Windows-1252")
        cipher = Cipher(algorithms.AES(self.key.encode("Windows-1252")), modes.CBC(iv))
        decryptor = cipher.decryptor()
        deciphered = decryptor.update(enc) + decryptor.finalize()
        plain = unpad(deciphered)
        return plain.decode("Windows-1252")
