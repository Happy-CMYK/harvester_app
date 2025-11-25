
import { Tabs } from 'antd';

const OrderPage = () => {

    return (
        <div>
            {/* Top Status Bar */}
            <div style={{ display: 'flex', justifyContent: 'space-between', backgroundColor: '#fffef0', padding: '10px' }}>
                <div style={{ color: '#e64319', textAlign: 'center', width: '50%' }}>
                    <span style={{ fontSize: '24px' }}>1</span>
                    <br />
                    待接单
                </div>
                <div style={{ color: '#f7a800', textAlign: 'center', width: '50%' }}>
                    <span style={{ fontSize: '24px' }}>1</span>
                    <br />
                    进行中
                </div>
            </div>

            {/* Removed navigation tabs as requested */}
        </div>
    );
};

export default OrderPage;

