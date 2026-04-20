using System.Security.Cryptography;
using System.Text;

namespace VaygoTech.Helpers
{
    public class EncryptionHelper
    {
        private readonly byte[] _key;
        private readonly byte[] _iv;

        public EncryptionHelper(IConfiguration config)
        {
            var rawKey = config["Encryption:Key"] ?? "VayGoDefault32ByteSecretKey12345";
            // AES-256 needs exactly 32 bytes
            _key = Encoding.UTF8.GetBytes(rawKey.PadRight(32).Substring(0, 32));
            // Fixed IV for deterministic encryption (use random IV + store alongside for production)
            _iv = Encoding.UTF8.GetBytes("VayGoIV16Bytes!!");
        }

        public string Encrypt(string plainText)
        {
            using var aes = Aes.Create();
            aes.Key = _key;
            aes.IV = _iv;
            var encryptor = aes.CreateEncryptor();
            var plainBytes = Encoding.UTF8.GetBytes(plainText);
            var encryptedBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
            return Convert.ToBase64String(encryptedBytes);
        }

        public string Decrypt(string encryptedText)
        {
            using var aes = Aes.Create();
            aes.Key = _key;
            aes.IV = _iv;
            var decryptor = aes.CreateDecryptor();
            var encryptedBytes = Convert.FromBase64String(encryptedText);
            var decryptedBytes = decryptor.TransformFinalBlock(encryptedBytes, 0, encryptedBytes.Length);
            return Encoding.UTF8.GetString(decryptedBytes);
        }

        public static string MaskAadhaar(string aadhaarNumber)
        {
            if (aadhaarNumber.Length == 12)
                return $"XXXX-XXXX-{aadhaarNumber.Substring(8)}";
            return "XXXX-XXXX-XXXX";
        }

        public static string ComputeHmacSha256(string data, string secret)
        {
            var keyBytes = Encoding.UTF8.GetBytes(secret);
            var dataBytes = Encoding.UTF8.GetBytes(data);
            using var hmac = new HMACSHA256(keyBytes);
            return Convert.ToHexString(hmac.ComputeHash(dataBytes)).ToLower();
        }
    }
}
