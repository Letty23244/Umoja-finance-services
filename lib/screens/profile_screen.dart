import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7E8BA), // Your light green background
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with your brown color - reduced height
          SliverAppBar(
            expandedHeight: 140, // Reduced height
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF795548), // Your brown
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF795548), // Your brown
                      const Color(0xFF795548).withOpacity(0.8), // Lighter brown
                      const Color(0xFFD7E8BA).withOpacity(0.3), // Your light green with opacity
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD7E8BA).withOpacity(0.2), // Your light green
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD7E8BA).withOpacity(0.2), // Your light green
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Profile Picture Section - Moved down significantly
              const SizedBox(height: 10), // Reduced space
              
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF795548).withOpacity(0.3), // Your brown with opacity
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65, // Slightly larger
                        backgroundColor: const Color(0xFF795548), // Your brown
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 60,
                              color: const Color(0xFFD7E8BA), // Your light green
                            ),
                            const Text(
                              "AL",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7E8BA), // Your light green
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: const Color(0xFF795548), // Your brown
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Space after avatar

              // Name and Info
              Column(
                children: [
                  const Text(
                    "Akullu Leticia",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF795548), // Your brown
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF795548).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "leticia@email.com",
                      style: const TextStyle(
                        color: Color(0xFF795548), // Your brown
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Verification badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF795548).withOpacity(0.1), // Your brown with opacity
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: const Color(0xFF795548), // Your brown
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Verified Member",
                          style: TextStyle(
                            color: Color(0xFF795548), // Your brown
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStatCard("Orders", "24", Icons.shopping_bag),
                    const SizedBox(width: 15),
                    _buildStatCard("Reviews", "12", Icons.star),
                    const SizedBox(width: 15),
                    _buildStatCard("Points", "2.5k", Icons.card_giftcard),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Profile Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF795548).withOpacity(0.1), // Your brown with opacity
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildEnhancedProfileTile(
                      Icons.phone_outlined,
                      "Phone Number",
                      "0700 000 000",
                      Icons.phone_iphone,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFFD7E8BA), thickness: 1), // Your light green
                    ),
                    _buildEnhancedProfileTile(
                      Icons.credit_card_outlined,
                      "Account Number",
                      "UF-2026-001",
                      Icons.verified_user,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFFD7E8BA), thickness: 1), // Your light green
                    ),
                    _buildEnhancedProfileTile(
                      Icons.calendar_today_outlined,
                      "Member Since",
                      "January 2026",
                      Icons.event_available,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF795548), // Your brown
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Settings Options
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF795548).withOpacity(0.1), // Your brown with opacity
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildEnhancedOption(
                      Icons.lock_outline,
                      "Change Password",
                      "Update your password",
                      () {},
                    ),
                    _buildEnhancedOption(
                      Icons.notifications_outlined,
                      "Notification Settings",
                      "Manage your alerts",
                      () {},
                    ),
                    _buildEnhancedOption(
                      Icons.help_outline,
                      "Help & Support",
                      "Get assistance",
                      () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF795548), // Your brown
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: const Color(0xFFD7E8BA)), // Your light green
                      const SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: const Color(0xFFD7E8BA), // Your light green
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF795548).withOpacity(0.1), // Your brown with opacity
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF795548), size: 28), // Your brown
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF795548), // Your brown
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF795548), // Your brown
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileTile(
    IconData icon,
    String title,
    String value,
    IconData trailingIcon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD7E8BA).withOpacity(0.3), // Your light green with opacity
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF795548), size: 22), // Your brown
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF795548), // Your brown
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548), // Your brown
                ),
              ),
            ],
          ),
        ),
        Icon(trailingIcon, color: const Color(0xFF795548), size: 20), // Your brown
      ],
    );
  }

  Widget _buildEnhancedOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD7E8BA).withOpacity(0.3), // Your light green with opacity
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF795548), size: 22), // Your brown
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF795548), // Your brown
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF795548), // Your brown
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD7E8BA).withOpacity(0.3), // Your light green with opacity
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Color(0xFF795548), // Your brown
        ),
      ),
      onTap: onTap,
    );
  }
}