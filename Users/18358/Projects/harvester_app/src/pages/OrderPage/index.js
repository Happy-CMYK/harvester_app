    return (
        <div>
            {/* Top Status Bar */}
            <div style={{ display: 'flex', justifyContent: 'space-between', backgroundColor: '#fffef0', padding: '10px' }}>
                <div style={{ color: '#f7a800', textAlign: 'center', width: '50%' }}>
                    <span style={{ fontSize: '24px' }}>1</span>
                    <br />
                    进行中
                </div>
            </div>

            {/* Navigation */}
            <Tabs defaultActiveKey="2" centered>
                <Tabs.TabPane tab="进行中 (1)" key="2">
                    {/* Remove order list content here */}
                </Tabs.TabPane>
            </Tabs>
        </div>
    );
};