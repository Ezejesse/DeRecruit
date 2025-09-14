DeRecruit
=========

* * * * *

Overview
--------

The `DeRecruit` smart contract is a decentralized application built on the Stacks blockchain, designed to revolutionize talent matching and recruitment. It provides a trustless, transparent, and secure platform for connecting employers with job seekers. By leveraging the power of smart contracts, it automates key processes such as **job posting**, **candidate applications**, **escrow payments**, and **reputation management**, eliminating the need for traditional intermediaries.

The contract's core features include:

-   **Decentralized Profiles**: Users can create and manage their profiles as either a **talent** (job seeker) or an **employer**, storing key information like skills, reputation, and job history directly on-chain.

-   **Trustless Escrow**: Payments for jobs are held in a secure **escrow contract**, which releases funds to the talent upon job completion and verification, ensuring both parties are protected.

-   **On-Chain Reputation**: A **reputation score** is maintained for both employers and talent, which increases with successful job completions, providing a reliable measure of trustworthiness and performance.

-   **Skill Verification**: The contract allows for the verification of skills by trusted network participants, adding a layer of authenticity to a talent's profile.

-   **Advanced Analytics (Future Feature)**: An advanced, AI-powered feature is included to demonstrate the contract's future potential. It performs intelligent talent matching, predictive success scoring, and market trend analysis, although its current implementation is a placeholder.

This contract provides a robust framework for a **decentralized autonomous organization (DAO)** or a **decentralized application (dApp)** focused on the future of work.

* * * * *

Contract Structure and Functions
--------------------------------

### Data Structures

The contract uses several maps and variables to store on-chain data:

-   `talent-profiles`: Maps a principal to a talent's profile, including their name, bio, skills, hourly rate, reputation, and job history.

-   `employer-profiles`: Maps a principal to an employer's profile, including their company details, reputation, and jobs posted.

-   `job-postings`: Stores details for each job, including the employer, title, description, required skills, payment amount, and status.

-   `job-applications`: Records each application by a talent for a specific job.

-   `escrow-contracts`: Manages the escrow for each job, holding funds and tracking the job's status.

-   `skill-verifications`: Stores skill verifications, linking a talent and a skill to a verifier.

### Public Functions

-   `create-talent-profile`: Allows a principal to create a new talent profile with their details.

-   `create-employer-profile`: Allows a principal to create a new employer profile.

-   `post-job`: An employer can post a new job, locking the `payment-amount` in the contract's balance.

-   `apply-for-job`: A talent can apply for an open job, providing a cover letter and proposed rate.

-   `select-candidate`: An employer selects a candidate, which initiates the escrow process and changes the job status to `IN_PROGRESS`.

-   `complete-job`: The selected candidate can call this function to complete the job. It triggers the release of the payment from the escrow, deducting the platform fee and updating the reputation scores of both parties.

-   `verify-skill`: Allows authorized principals (e.g., verified employers or high-reputation talent) to verify a specific skill for another talent.

-   `execute-intelligent-talent-matching-analysis`: A placeholder function for an advanced feature that would perform AI-driven talent matching. It demonstrates the extensibility of the contract for future sophisticated features.

### Private Functions

-   `calculate-platform-fee`: A helper function to compute the platform fee based on the payment amount.

-   `is-job-employer`: Verifies if the caller is the employer who posted a specific job.

-   `update-reputation`: A function to update a user's reputation score.

-   `calculate-skill-match`: A helper function to determine the compatibility between a job's required skills and a candidate's skills.

-   `check-skill-match`: A placeholder for a more complex skill-matching logic.

* * * * *

Error Codes
-----------

The contract uses standard error codes to handle different failure conditions:

-   `u100`: `ERR-UNAUTHORIZED` - The caller is not authorized to perform the action.

-   `u101`: `ERR-JOB-NOT-FOUND` - The specified job does not exist.

-   `u102`: `ERR-CANDIDATE-NOT-FOUND` - The specified candidate's profile does not exist.

-   `u103`: `ERR-ALREADY-APPLIED` - Not currently used in the provided code, but reserved for future functionality.

-   `u104`: `ERR-INSUFFICIENT-PAYMENT` - The payment amount is below the minimum required.

-   `u105`: `ERR-JOB-NOT-ACTIVE` - The job is not in the correct status to proceed.

-   `u106`: `ERR-INVALID-STATUS` - The contract's current status or provided parameters are invalid.

-   `u107`: `ERR-ESCROW-NOT-FOUND` - The escrow contract for the specified job does not exist.

-   `u108`: `ERR-APPLICATION-NOT-FOUND` - The specified application does not exist.

* * * * *

Installation and Usage
----------------------

To deploy and interact with the `DeRecruit` contract, you will need a Stacks wallet and access to a Stacks blockchain environment (e.g., testnet or mainnet).

### Deployment

1.  **Clone this repository** or copy the contract code.

2.  **Use the Stacks CLI** or a web-based IDE like the **Clarinet** tool to compile and deploy the contract.

3.  Deploy the contract to your desired Stacks network. Note the contract address for future interactions.

### Interaction

You can interact with the contract's public functions using the Stacks CLI or a dApp front-end. Here are some example commands:

-   **Create a talent profile**:

    ```
    (contract-call? 'SP123...DeRecruit create-talent-profile "John Doe" "Full-stack developer with 5+ years experience." '("Clarity" "React" "TypeScript") u500000)

    ```

-   **Post a job**:

    ```
    (contract-call? 'SP123...DeRecruit post-job "Senior Clarity Developer" "Build a new DeFi protocol" '("Clarity" "Smart Contracts") u2000000 u1200)

    ```

-   **Apply for a job**:

    ```
    (contract-call? 'SP123...DeRecruit apply-for-job u1 "I am an expert in Clarity and would love to work on this project." u1800000)

    ```

*Note: Replace `SP123...DeRecruit` with your deployed contract's address.*

* * * * *

Contribution
------------

We welcome contributions to the `DeRecruit` project! To contribute:

1.  **Fork the repository**.

2.  **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name`.

3.  **Make your changes**, ensuring they adhere to the Clarity language best practices.

4.  **Write tests** for your changes using the Clarinet testing framework.

5.  **Submit a pull request** with a detailed description of your changes and why they are necessary.

Please read the **CONTRIBUTING.md** file for more details.

* * * * *

License
-------

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Ezejesse

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

* * * * *

Disclaimer
----------

This contract is provided "as is," without warranty of any kind. It has not been formally audited and should not be used in a production environment without a thorough security review by qualified professionals. The development team is not liable for any losses or damages incurred from the use of this software.
