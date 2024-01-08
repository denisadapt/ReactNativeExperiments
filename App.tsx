/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState} from 'react';
import type {PropsWithChildren} from 'react';
import {
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  // NativeModules,
} from 'react-native';

import {Colors, Header} from 'react-native/Libraries/NewAppScreen';

import {AdaptEnvironment} from './addon';

// import RNFS from 'react-native-fs';

// const {AdaptWrapper} = NativeModules;

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({children, title}: SectionProps): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={styles.sectionContainer}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        {title}
      </Text>
      <Text
        style={[
          styles.sectionDescription,
          {
            color: isDarkMode ? Colors.light : Colors.dark,
          },
        ]}>
        {children}
      </Text>
    </View>
  );
}

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [greeting, setGreeting] = useState('');
  // const [addition, setAddition] = useState(0);
  // const [fileContents, setFileContents] = useState('');

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const showGreeting = async () => {
    try {
      setGreeting('Initializing...');
      AdaptEnvironment.Initialize(true);
      setGreeting('Initialized');
      const systemTime = AdaptEnvironment.SystemTime();
      setGreeting('Got system time');
      const systemTimeStr = systemTime.Visualize();
      // const greetingStr = await AdaptWrapper.greet('World');
      setGreeting(systemTimeStr);
    } catch (e) {
      console.error(e);
    }
  };

  // const showAddition = async () => {
  //   // try {
  //   //   const result = await AdaptWrapper.add(5, 3);
  //   //   setAddition(`Result: ${result}`);
  //   // } catch (e) {
  //   //   console.error(e);
  //   // }
  // };
  //
  // const readLocalFile = async () => {
  //   // try {
  //   //   console.log(RNFS.MainBundlePath);
  //   //   const result = await AdaptWrapper.readFileContents(
  //   //     RNFS.MainBundlePath + '/test.txt',
  //   //   );
  //   //   setFileContents(`Result: ${result}`);
  //   // } catch (e) {
  //   //   console.error(e);
  //   // }
  // };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Header />
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}>
          <Section title="Greeting">
            <Text>{greeting}</Text>
            <Button title="Greet" onPress={showGreeting} />
          </Section>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
