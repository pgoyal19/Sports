# 🏆 GoChamp - AI-Powered Sports Talent Assessment

**SAI Scout - AI-powered sports talent assessment for rural India**

GoChamp is a comprehensive mobile application that uses AI, AR, and blockchain technology to assess sports talent in rural India. The app provides real-time performance analysis, gamified experiences, and secure blockchain verification of achievements.

## ✨ Features

### 🎯 Core Features
- **AI-Powered Assessment**: Real-time pose detection and performance analysis
- **AR-Guided Testing**: Camera-based setup with virtual markers
- **Multi-Language Support**: English, Hindi, Bengali, Tamil
- **Blockchain Verification**: Tamper-proof achievement records
- **Gamification**: Badges, leaderboards, and progress tracking
- **Offline Capability**: Works without internet connection

### 📱 Technical Features
- **Camera Integration**: Video recording and pose detection
- **Location Services**: GPS-based AR features
- **Push Notifications**: Achievement alerts and updates
- **Data Persistence**: Local storage with cloud sync
- **Responsive UI**: Modern Material Design 3 interface

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.9.2+)
- Android Studio / VS Code
- Android device or emulator (API 21+)
- Python 3.8+ (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sports-talent-assessment
   ```

2. **Build the APK**
   ```bash
   # Run the automated build script
   BUILD_APK.bat
   
   # Or manually:
   cd mobile_app
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

3. **Install on Android device**
   - Enable "Install from Unknown Sources"
   - Copy APK to device and install
   - Grant all required permissions

### Backend Setup (Optional)

For full AI analysis features:

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
python main.py
```

## 📱 App Structure

### Screens
- **Splash Screen**: Animated welcome with branding
- **Phone Auth**: OTP-based authentication
- **Home Shell**: Main navigation with bottom tabs
- **AR Test Setup**: Camera-guided test preparation
- **Record Test**: Video recording with real-time feedback
- **Results**: Detailed performance analysis
- **Leaderboard**: Multi-level rankings
- **Profile**: User management and settings

### Services
- **AuthService**: Phone-based authentication
- **ApiService**: Backend communication
- **LanguageService**: Multi-language support
- **TranslationService**: Localization management

### Providers
- **AthleteProvider**: User profile management
- **GamificationProvider**: Badges and scoring
- **BlockchainProvider**: NFT and verification

## 🎮 Usage

### For Athletes
1. **Register**: Enter phone number and verify OTP
2. **Create Profile**: Add personal information and sport preference
3. **Take Tests**: Follow AR guidance for proper setup
4. **View Results**: Get detailed performance analysis
5. **Track Progress**: Monitor improvements over time

### For Coaches/SAI Officials
1. **Access Dashboard**: View aggregated performance data
2. **Filter Analytics**: By state, sport, age group
3. **Monitor Trends**: Performance patterns and insights
4. **Verify Results**: Blockchain-verified achievements

## 🔧 Configuration

### API Endpoints
The app automatically detects the correct API URL based on platform:
- **Web**: `http://127.0.0.1:8000`
- **Android Emulator**: `http://10.0.2.2:8000`
- **Physical Device**: Configure manually if needed

### Permissions Required
- **Camera**: Video recording and AR features
- **Location**: GPS-based functionality
- **Storage**: Save videos and data
- **Microphone**: Audio recording
- **Internet**: Backend communication

## 🏗️ Architecture

### Frontend (Flutter)
- **State Management**: Provider pattern
- **UI Framework**: Material Design 3
- **Localization**: Easy Localization
- **Charts**: FL Chart for analytics
- **Animations**: Lottie for smooth transitions

### Backend (FastAPI)
- **Framework**: FastAPI with Python
- **AI Models**: TensorFlow Lite for pose detection
- **Database**: In-memory for demo (extensible)
- **Authentication**: JWT tokens
- **File Handling**: Multipart uploads

### Blockchain
- **Technology**: Simulated blockchain for demo
- **Features**: Transaction recording, NFT badges
- **Security**: Hash-based verification

## 📊 Performance Analysis

The AI system analyzes:
- **Form & Technique**: Body alignment and movement patterns
- **Consistency**: Performance stability over time
- **Power & Speed**: Explosive movements and velocity
- **Technical Execution**: Skill-specific metrics

## 🌐 Multi-Language Support

Supported languages:
- **English** (en): Default language
- **Hindi** (hi): हिन्दी
- **Bengali** (bn): বাংলা
- **Tamil** (ta): தமிழ்

## 🔒 Security & Privacy

- **Data Encryption**: Secure transmission and storage
- **Blockchain Verification**: Tamper-proof records
- **Privacy Compliance**: GDPR-ready data handling
- **Secure Authentication**: OTP-based verification

## 🚀 Deployment

### APK Distribution
1. **Build APK**: Use `BUILD_APK.bat` script
2. **Choose Version**: 
   - `app-arm64-v8a-release.apk` (64-bit devices)
   - `app-armeabi-v7a-release.apk` (32-bit devices)
   - `app-release.apk` (universal)
3. **Distribute**: Share via file transfer or cloud storage

### Backend Deployment
- **Local Development**: Python virtual environment
- **Production**: Docker containers recommended
- **Cloud**: AWS, GCP, or Azure compatible

## 🐛 Troubleshooting

### Common Issues

**App won't install**
- Enable "Install from Unknown Sources"
- Check device storage (100MB+ required)
- Uninstall previous versions

**Camera not working**
- Grant camera permission
- Check if another app is using camera
- Restart the app

**Backend connection failed**
- Check network connectivity
- Verify API URL configuration
- Ensure backend server is running

**Performance issues**
- Close other apps to free RAM
- Check device compatibility (Android 5.0+)
- Restart device if needed

## 📈 Future Enhancements

- **Real Blockchain Integration**: Ethereum/Polygon support
- **Advanced AI Models**: More sophisticated pose analysis
- **Social Features**: Community challenges and sharing
- **Wearable Integration**: Smartwatch compatibility
- **Cloud Analytics**: Advanced performance insights

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **SAI (Sports Authority of India)**: For the vision and support
- **Flutter Team**: For the excellent framework
- **TensorFlow**: For AI model capabilities
- **Open Source Community**: For various dependencies

## 📞 Support

For support and questions:
- **Email**: support@gochamp.app
- **Documentation**: [Wiki](link-to-wiki)
- **Issues**: [GitHub Issues](link-to-issues)

---

**Made with ❤️ for Indian Sports Talent**
