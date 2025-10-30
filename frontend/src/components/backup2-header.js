// Header.js
import React from 'react';
import { View, Text, Image, StyleSheet, Linking } from 'react-native';
import { TouchableRipple, Surface, Button } from 'react-native-paper';
import { WIKI_URL, DMS_URL } from '@env';

const Header = ({ onAboutPress, onServicesPress, isLoggedIn, onAuthPress }) => {
  
  // Function to open external URLs
  const openExternalLink = (url) => {
    Linking.openURL(url).catch((err) => console.error('Failed to open URL:', err));
  };

  return (
    <Surface style={styles.header} elevation={4}>
      {/* Left Section: Logo + Text */}
      <View style={styles.leftSection}>
        <Image
          source={require('../../assets/grenada-flag.png')}
          style={styles.logo}
        />
        <View>
          <Text style={styles.title}>Government of Grenada</Text>
          <Text style={styles.subtitle}>EA Portal</Text>
        </View>
      </View>

      {/* Right Section: Navigation Links + Search Button + Login/Logout Button */}
      <View style={styles.rightSection}>
        <View style={styles.navLinks}>
          {/* About Link */}
          <TouchableRipple onPress={onAboutPress} borderless>
            <Text style={styles.navItem}>About</Text>
          </TouchableRipple>

          {/* COMMENTED OUT - Framework Link */}
          {/* <TouchableRipple onPress={onFrameworkPress} borderless>
            <Text style={styles.navItem}>Framework</Text>
          </TouchableRipple> */}

          {/* NEW - Repository (DMS) External Link */}
          <TouchableRipple onPress={() => openExternalLink(DMS_URL)} borderless>
            <Text style={styles.navItem}>Repository (DMS)</Text>
          </TouchableRipple>

          {/* NEW - Wiki External Link */}
          <TouchableRipple onPress={() => openExternalLink(WIKI_URL)} borderless>
            <Text style={styles.navItem}>Wiki</Text>
          </TouchableRipple>

          {/* Services Link */}
          <TouchableRipple onPress={onServicesPress} borderless>
            <Text style={styles.navItem}>Services</Text>
          </TouchableRipple>

          {/* COMMENTED OUT - Maturity Model Link */}
          {/* <TouchableRipple onPress={onMaturityPress} borderless>
            <Text style={styles.navItem}>Maturity model</Text>
          </TouchableRipple> */}
        </View>
        <Button
          mode="contained"
          onPress={() => {}}
          style={styles.searchButton}
          labelStyle={styles.searchText}
        >
          SEARCH
        </Button>
        <Button
          mode="outlined"
          onPress={onAuthPress}
          style={styles.authButton}
          labelStyle={styles.authText}
        >
          {isLoggedIn ? 'Logout' : 'Login'}
        </Button>
      </View>
    </Surface>
  );
};

export default Header;

const styles = StyleSheet.create({
  header: {
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: '#fff',
  },
  leftSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 40,
    height: 25,
    marginRight: 8,
  },
  title: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 12,
    color: '#666',
  },
  rightSection: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 20,
  },
  navLinks: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 20,
  },
  navItem: {
    fontSize: 14,
    fontWeight: '500',
    color: '#000',
  },
  searchButton: {
    backgroundColor: '#000',
    borderRadius: 4,
  },
  searchText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  authButton: {
    borderRadius: 4,
    borderColor: '#000',
    paddingHorizontal: 8,
  },
  authText: {
    fontSize: 14,
    fontWeight: 'bold',
  },
});
