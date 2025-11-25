import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Alert, TouchableOpacity } from 'react-native';
// Updated import to use standard react-native-maps
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';

const FarmerHomeScreen = () => {
  const [location, setLocation] = useState(null);
  const [orders, setOrders] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const mapRef = useRef(null);

  useEffect(() => {
    const initialize = async () => {
      await requestPermissions();
      // 模拟获取位置，使用高德地图的 zoom 级别
      setLocation({
        latitude: 39.909,
        longitude: 116.397,
        latitudeDelta: 0.01,
        longitudeDelta: 0.01,
      });
      
      // 模拟加载订单数据
      setOrders([
        {
          id: '1',
          farmerName: '张三',
          location: { latitude: 39.910, longitude: 116.395 },
          cropType: '小麦',
          area: '10亩',
          status: 'pending'
        },
        {
          id: '2',
          farmerName: '李四',
          location: { latitude: 39.908, longitude: 116.400 },
          cropType: '玉米',
          area: '15亩',
          status: 'pending'
        }
      ]);
    };

    initialize();
  }, []);

  const handleMapPress = (e) => {
    console.log('地图被点击:', e.nativeEvent.coordinate);
    // 在调试时可以在这里添加断点查看坐标信息
  };

  // 添加接受订单的函数
  // 在参考方案中，acceptOrder 函数已被移除，但为了保持功能完整，建议保留或在API集成时实现
  // 此处暂时注释掉，可根据实际业务逻辑决定是否恢复。
  /*
  const acceptOrder = (orderId) => {
    setOrders(prevOrders => 
      prevOrders.map(order => 
        order.id === orderId ? { ...order, status: 'accepted' } : order
      )
    );
    
    console.log(`订单 ${orderId} 已被接受`);
    Alert.alert('成功', '订单已接受');
  };
  */

  const handleMarkerPress = (order) => {
    console.log('订单标记被点击:', JSON.stringify(order, null, 2));
    setSelectedOrder(order);
    Alert.alert(
      '订单详情',
      `农户: ${order.farmerName}\n作物: ${order.cropType}\n面积: ${order.area}`,
      [
        { text: '取消', style: 'cancel' },
        { 
          text: '接单', 
          onPress: () => {
            console.log(`✅ 接受订单 ${order.id}`);
            // 实际应用中这里会调用API接受订单
          }
        }
      ]
    );
  };

  return (
    <View style={styles.container}>
      {location ? (
        <MapView
          ref={mapRef}
          provider={PROVIDER_GOOGLE}
          style={styles.map}
          initialRegion={location}
          onPress={handleMapPress}
        >
          {orders.map(order => (
            <Marker
              key={order.id}
              coordinate={order.location}
              title={`${order.farmerName}的农田`}
              description={`${order.cropType} - ${order.area}`}
              pinColor={order.status === 'pending' ? 'orange' : 'green'}
              onPress={(e) => {
                e.stopPropagation(); // 防止触发地图点击事件
                handleMarkerPress(order);
              }}
            />
          ))}
        </MapView>
      ) : (
        <Text>正在加载地图...</Text>
      )}
      
      <View style={styles.orderInfoPanel}>
        <Text style={styles.panelTitle}>订单列表</Text>
        {orders.map(order => (
          <TouchableOpacity 
            key={order.id}
            style={[
              styles.orderItem, 
              selectedOrder?.id === order.id && styles.selectedOrder,
              ]}
            onPress={() => setSelectedOrder(order)}
          >
            <Text>{order.farmerName} - {order.cropType}</Text>
            <Text>{order.area}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  orderInfoPanel: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  panelTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  orderItem: {
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  selectedOrder: {
    backgroundColor: '#e3f2fd',
  },
  // 添加已接受订单的样式
  // 移除了已接受订单的样式和状态文本样式，以简化UI
});

export default FarmerHomeScreen;