import React from 'react';
import { Alert, Button, NativeModules } from 'react-native';

const MyComponent = () => {
    const handleAdd = () => {
        NativeModules.MyTurboModule.add(5, 3, (error, result) => {
            if (error) {
                Alert.alert("Error", error.message);
            } else {
                Alert.alert("Result", `The result is ${result}`);
            }
        });
    };

    return (
        <Button title="Add 5 and 3" onPress={handleAdd} />
    );
};

export default MyComponent;
