import Foundation
import CryptoKit

let privateKeyA = Curve25519.KeyAgreement.PrivateKey()
let privateKeyB = Curve25519.KeyAgreement.PrivateKey()
let secret = UUID().uuidString
let secretData = Data(secret.utf8)
let salt = UUID().uuidString
let saltData = Data(salt.utf8)
let shared = UUID().uuidString
let sharedData = Data(shared.utf8)
let byteCount = 32
let hash = SHA512.self

extension Data {
    var hex: String { map { String(format: "%02hhx", $0) }.joined() }
}

extension Curve25519 {
    static func encrypt<Hash: HashFunction>(secret: Data,
                                            salt: Data,
                                            shared: Data,
                                            byteCount: Int,
                                            hash: Hash.Type,
                                            senderPrivateKey privateKey: Curve25519.KeyAgreement.PrivateKey,
                                            publicKey: Curve25519.KeyAgreement.PublicKey) throws -> Data {
        try ChaChaPoly.seal(
            secret,
            using: (
                try symmetricKey(
                    salt: salt,
                    shared: shared,
                    byteCount: byteCount,
                    hash: hash,
                    privateKey: privateKey,
                    senderPublicKey: publicKey)
            )
        )
        .combined
    }
    
    static func decrypt<Hash: HashFunction>(combined: Data,
                                            salt: Data,
                                            shared: Data,
                                            byteCount: Int,
                                            hash: Hash.Type,
                                            privateKey: Curve25519.KeyAgreement.PrivateKey,
                                            senderPublicKey publicKey: Curve25519.KeyAgreement.PublicKey) throws -> Data {
        try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: combined),
            using: try symmetricKey(
                salt: salt,
                shared: shared,
                byteCount: byteCount,
                hash: hash,
                privateKey: privateKey,
                senderPublicKey: publicKey
            )
        )
    }
    
    static func sharedSecret(privateKey: Curve25519.KeyAgreement.PrivateKey,
                             senderPublicKey publicKey: Curve25519.KeyAgreement.PublicKey) throws -> SharedSecret {
        try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
    }
    
    static func symmetricKey<Hash: HashFunction>(salt: Data,
                                                 shared: Data,
                                                 byteCount: Int,
                                                 hash: Hash.Type,
                                                 privateKey: Curve25519.KeyAgreement.PrivateKey,
                                                 senderPublicKey publicKey: Curve25519.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let symmetricKey = (try sharedSecret(privateKey: privateKey, senderPublicKey: publicKey))
            .hkdfDerivedSymmetricKey(using: hash,
                                     salt: salt,
                                     sharedInfo: shared,
                                     outputByteCount: byteCount)
        return symmetricKey
    }
}

do {
    print(secret)
    let encrypted = try Curve25519.encrypt(secret: secretData,
                                           salt: saltData,
                                           shared: sharedData,
                                           byteCount: byteCount,
                                           hash: hash,
                                           senderPrivateKey: privateKeyA,
                                           publicKey: privateKeyB.publicKey)
    print(encrypted.hex)
    let decrypted = try Curve25519.decrypt(combined: encrypted,
                                           salt: saltData,
                                           shared: sharedData,
                                           byteCount: byteCount,
                                           hash: hash,
                                           privateKey: privateKeyB,
                                           senderPublicKey: privateKeyA.publicKey)
    print(String(data: decrypted, encoding: .utf8) ?? "Unable to construct decrypted string")
} catch {
    print("🛑 \(error)")
}
