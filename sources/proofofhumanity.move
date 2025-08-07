
module addr::ProofOfHumanity {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::String;
    /// Error codes
    const E_ALREADY_VERIFIED: u64 = 1;
    const E_NOT_VERIFIED: u64 = 2;
    const E_VERIFICATION_EXPIRED: u64 = 3;

    /// Struct representing a human verification record
    struct HumanVerification has store, key {
        is_verified: bool,          // Verification status
        verification_time: u64,     // Timestamp of verification
        verification_method: String, // Method used for verification
        expiry_time: u64,          // When verification expires
    }

    /// Function to verify a human identity
    public fun verify_human(
        user: &signer, 
        verification_method: String, 
        validity_period: u64
    ) {
        let user_addr = signer::address_of(user);
        
        // Check if user is already verified
        assert!(!exists<HumanVerification>(user_addr), E_ALREADY_VERIFIED);
        
        let current_time = timestamp::now_seconds();
        let expiry_time = current_time + validity_period;
        
        let verification = HumanVerification {
            is_verified: true,
            verification_time: current_time,
            verification_method,
            expiry_time,
        };
        
        move_to(user, verification);
    }

    /// Function to check if a user is verified and verification is still valid
    public fun is_human_verified(user_address: address): bool acquires HumanVerification {
        if (!exists<HumanVerification>(user_address)) {
            return false
        };
        
        let verification = borrow_global<HumanVerification>(user_address);
        let current_time = timestamp::now_seconds();
        
        // Check if verification exists, is valid, and not expired
        verification.is_verified && current_time <= verification.expiry_time
    }
}